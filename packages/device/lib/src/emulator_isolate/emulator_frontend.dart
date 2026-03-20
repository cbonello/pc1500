import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/emulator.dart';
import 'package:device/src/messages/messages.dart';
import 'package:device/src/messages/messages_base.dart';
import 'package:meta/meta.dart';

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

  /// Exposed for unit tests — processes a serialized emulator message.
  @visibleForTesting
  void handleMessageForTest(Uint8List data) => _messageHandler(data);

  void _messageHandler(Uint8List data) {
    try {
      final EmulatorMessageId emulatorMessageId =
          EmulatorMessageId.values[data[0]];

      switch (emulatorMessageId) {
        case EmulatorMessageId.startEmulator:
          final message = StartEmulatorMessageSerializer().deserialize(data);
          assert(emulator == null);
          type = message.type;
          emulator = Emulator(type, outPort);
          debugPort = message.debugPort;
          _startDebugServer(debugPort);
        // Don't start the CPU yet — the real PC-1500 stays powered off
        // until the ON key is pressed. run() is called on first ON key.
        case EmulatorMessageId.updateDeviceType:
          final UpdateDeviceTypeMessage message =
              UpdateDeviceTypeMessageSerializer().deserialize(data);
          if (message.type != type) {
            type = message.type;
            // Recreate the emulator with the new hardware type.
            // This changes RAM size, memory layout, etc.
            emulator?.stop();
            emulator = Emulator(type, outPort);
          }
        case EmulatorMessageId.keyDown:
          final KeyEventMessage msg = KeyEventMessageSerializer().deserialize(
            data,
          );
          // Keys handled outside the keyboard matrix.
          if (msg.keyName == 'on') {
            emulator?.powerOn();
            break;
          }
          if (msg.keyName == 'off') {
            emulator?.powerOff();
            break;
          }
          if (msg.keyName == 'mode') {
            emulator?.cycleMode();
            break;
          }
          if (msg.keyName == 'shift') {
            emulator?.toggleShift();
            break;
          }
          emulator?.keyboard.keyDown(msg.keyName);
          emulator?.updateKeyboardInput();
        case EmulatorMessageId.keyUp:
          final KeyEventMessage msg = KeyEventMessageSerializer().deserialize(
            data,
          );
          emulator?.keyboard.keyUp(msg.keyName);
          emulator?.updateKeyboardInput();
        case EmulatorMessageId.step:
          emulator?.step();
        default:
          break;
      }
    } catch (e, st) {
      // Log but don't crash — the emulator isolate must stay alive.
      assert(() {
        // ignore: avoid_print
        print('Emulator message error: $e\n$st');
        return true;
      }());
    }
  }

  Future<void> _startDebugServer(int debugPort) async {
    if (serverSocket != null) {
      _stopDebuggerServer();
    }

    try {
      serverSocket = await ServerSocket.bind('localhost', debugPort);
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('Debug server bind failed on port $debugPort: $e');
        return true;
      }());
      return;
    }

    serverSocketSub = serverSocket!.listen(
      (Socket client) {
        if (isDebugClientConnected) {
          client.close(); // Only one debug client at a time.
          return;
        }
        _updateDebuggerStatus(true);
        client.listen(
          _messageHandler,
          onError: (Object error) {
            _updateDebuggerStatus(false);
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
    serverSocketSub = null;
    serverSocket?.close();
    serverSocket = null;
    isDebugClientConnected = false;
  }
}
