import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../device.dart';
import '../messages/messages.dart';
import '../messages/messages_base.dart';
import 'emulator.dart';

EmulatorFrontEnd _frontEnd;

void emulatorLaunch(SendPort outPort) =>
    _frontEnd ??= EmulatorFrontEnd(outPort: outPort);

class EmulatorFrontEnd {
  EmulatorFrontEnd({@required this.outPort}) : assert(outPort != null) {
    final ReceivePort inStream = ReceivePort();
    outPort.send(inStream.sendPort);

    inStreamSub = inStream.listen((dynamic data) {
      _messageHandler(data as Uint8List);
    });

    isDebugClientConnected = false;
  }

  SendPort outPort;
  StreamSubscription<dynamic> inStreamSub;
  HardwareDeviceType type;
  int debugPort;
  Emulator emulator;

  ServerSocket serverSocket;
  StreamSubscription<Socket> serverSocketSub;
  bool isDebugClientConnected;

  void dispose() {
    inStreamSub?.cancel();
    _stopDebuggerServer();
  }

  void _messageHandler(Uint8List data) {
    try {
      final EmulatorMessageId emulatorMessageId =
          EmulatorMessageId.values[data[0]];

      switch (emulatorMessageId) {
        case EmulatorMessageId.startEmulator:
          final StartEmulatorMessage message =
              StartEmulatorMessageSerializer().deserialize(data);
          assert(emulator == null);
          type = message.type;
          emulator = Emulator(type, outPort);
          debugPort = message.debugPort;
          _startDebugServer(debugPort);
          break;
        case EmulatorMessageId.updateDeviceType:
          final UpdateDeviceTypeMessage message =
              UpdateDeviceTypeMessageSerializer().deserialize(data);
          type = message.type;
          break;
        case EmulatorMessageId.updateDebugPort:
          final UpdateDebugPortMessage message =
              UpdateDebugPortMessageSerializer().deserialize(data);
          debugPort = message.port;
          break;
        case EmulatorMessageId.step:
          print('EmulatorMessageId.step');
          break;
        default:
          print('### RECEIVED: $data');
      }
    } catch (_) {
      print('### RECEIVED: $data');
    }
  }

  Future<void> _startDebugServer(int debugPort) async {
    if (serverSocket != null) {
      _stopDebuggerServer();
    }

    serverSocket = await ServerSocket.bind(
      'localhost', //InternetAddress.anyIPv4,
      debugPort,
    );

    serverSocketSub = serverSocket.listen(
      isDebugClientConnected
          ? null
          : (Socket client) {
              _updateDebuggerStatus(true);
              client.listen(
                _messageHandler,
                onError: (Object error) {
                  print('Error: $error');
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
