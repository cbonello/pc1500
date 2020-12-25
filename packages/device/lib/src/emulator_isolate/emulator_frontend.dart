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

    inStream.listen((dynamic data) {
      _messageHandler(data as Uint8List);
    });
  }

  SendPort outPort;
  DeviceType type;
  int debugPort;
  Emulator emulator;

  ServerSocket serverSocket;
  _DebugClient debugClient;

  void _messageHandler(Uint8List data) {
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
      default:
        throw Exception();
    }
  }

  Future<void> _startDebugServer(int debugPort) async {
    serverSocket = await ServerSocket.bind(
      'localhost', //InternetAddress.anyIPv4,
      debugPort,
    );

    serverSocket.listen(
      (Socket client) => debugClient ??= _DebugClient(client, _messageHandler),
      onError: (Object _) {},
      onDone: () {
        debugClient?.dispose();
        debugClient = null;
      },
    );
  }
}

class _DebugClient {
  _DebugClient(
    this.socket,
    this.messageHandler,
  ) {
    _address = socket.remoteAddress.address;
    _port = socket.remotePort;

    print('Debug server listening on $_address:$_port');

    _debugSub = socket.listen(
      messageHandler,
      onError: errorHandler,
      onDone: finishedHandler,
    );
  }

  Socket socket;
  void Function(Uint8List data) messageHandler;

  String _address;
  int _port;
  StreamSubscription<Uint8List> _debugSub;

  void errorHandler(Object error) {
    print('$_address:$_port Error: $error');
    socket.close();
  }

  void finishedHandler() {
    print('$_address:$_port Disconnected');
    socket.close();
  }

  void write(String message) {
    socket.write(message);
  }

  void dispose() {
    _debugSub?.cancel();
  }
}
