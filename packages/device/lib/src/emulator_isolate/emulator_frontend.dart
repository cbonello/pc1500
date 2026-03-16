import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/emulator.dart';
import 'package:device/src/messages/messages.dart';
import 'package:device/src/messages/messages_base.dart';

EmulatorFrontEnd? _frontEnd;

void runEmulator(SendPort outPort) {
  _frontEnd ??= EmulatorFrontEnd(outPort: outPort);
}

void killEmulator() {
  _frontEnd?.dispose();
  _frontEnd = null;
}

class EmulatorFrontEnd {
  EmulatorFrontEnd({required this.outPort}) {
    final ReceivePort inStream = ReceivePort();
    outPort.send(inStream.sendPort);

    inStreamSub = inStream.listen((dynamic data) {
      _messageHandler(data as Uint8List);
    });

    isDebugClientConnected = false;
  }

  final SendPort outPort;
  late StreamSubscription<dynamic> inStreamSub;
  late HardwareDeviceType type;
  late int debugPort;
  Emulator? emulator;

  ServerSocket? serverSocket;
  StreamSubscription<Socket>? serverSocketSub;
  bool isDebugClientConnected = false;

  void dispose() {
    emulator?.stop();
    emulator?.dispose();
    emulator = null;
    inStreamSub.cancel();
    _stopDebuggerServer();
  }

  void _messageHandler(Uint8List data) {
    try {
      final EmulatorMessageId emulatorMessageId =
          EmulatorMessageId.values[data[0]];

      switch (emulatorMessageId) {
        case EmulatorMessageId.startEmulator:
          final StartEmulatorMessage message = StartEmulatorMessageSerializer()
              .deserialize(data);
          assert(emulator == null);
          type = message.type;
          emulator = Emulator(type, outPort);
          debugPort = message.debugPort;
          _startDebugServer(debugPort);
          // Schedule the emulation loop to start after this handler returns,
          // so the ReceivePort can process messages between frames.
          scheduleMicrotask(() => emulator?.run());
        case EmulatorMessageId.updateDeviceType:
          final UpdateDeviceTypeMessage message =
              UpdateDeviceTypeMessageSerializer().deserialize(data);
          type = message.type;
        case EmulatorMessageId.keyDown:
          final KeyEventMessage msg =
              KeyEventMessageSerializer().deserialize(data);
          emulator?.keyboard.keyDown(msg.keyName);
        case EmulatorMessageId.keyUp:
          final KeyEventMessage msg =
              KeyEventMessageSerializer().deserialize(data);
          emulator?.keyboard.keyUp(msg.keyName);
        case EmulatorMessageId.step:
          emulator?.step();
        default:
          break;
      }
    } catch (_) {
      // Ignore malformed messages.
    }
  }

  Future<void> _startDebugServer(int debugPort) async {
    if (serverSocket != null) {
      _stopDebuggerServer();
    }

    serverSocket = await ServerSocket.bind('localhost', debugPort);

    serverSocketSub = serverSocket!.listen(
      isDebugClientConnected
          ? null
          : (Socket client) {
              _updateDebuggerStatus(true);
              client.listen(
                _messageHandler,
                onError: (Object error) {
                  client.close();
                },
                onDone: () {
                  _updateDebuggerStatus(false);
                  client.close();
                },
              );
            },
      onError: (Object _) {},
      onDone: () => _updateDebuggerStatus(false),
    );
  }

  void _updateDebuggerStatus(bool debugClientStatus) {
    isDebugClientConnected = debugClientStatus;

    final IsDebugClientConnectedMessage idc = IsDebugClientConnectedMessage(
      status: isDebugClientConnected,
    );
    outPort.send(IsDebugClientConnectedMessageSerializer().serialize(idc));
  }

  void _stopDebuggerServer() {
    serverSocketSub?.cancel();
    serverSocket?.close();
  }
}
