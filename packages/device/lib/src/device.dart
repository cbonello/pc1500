import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:device/src/emulator_isolate/emulator_frontend.dart';
import 'package:device/src/messages/messages.dart';
import 'package:device/src/messages/messages_base.dart';
import 'package:lcd/lcd.dart';

enum HardwareDeviceType { pc1500, pc1500A }

class Device {
  Device({required HardwareDeviceType type, required int debugPort})
    : _type = type,
      _debugPort = debugPort,
      _outEventCtrl = StreamController<LcdEvent>.broadcast(),
      isDebugClientConnected = false;

  bool isDebugClientConnected;

  HardwareDeviceType _type;
  final int _debugPort;
  final StreamController<LcdEvent> _outEventCtrl;
  Isolate? _isolate;
  SendPort? _toEmulatorPort;
  StreamSubscription<dynamic>? _fromEmulatorSub;

  HardwareDeviceType get hardwareDeviceType => _type;
  set hardwareDeviceType(HardwareDeviceType newType) {
    if (newType != _type) {
      _type = newType;
      if (_isEmulatorRunning) {
        kill();
      }
      run();
    }
  }

  Stream<LcdEvent> get lcdEvents => _outEventCtrl.stream;

  bool get _isEmulatorRunning => _isolate != null;

  Future<void> run() async {
    if (_isEmulatorRunning == false) {
      _toEmulatorPort = await _initIsolate();

      _send(
        StartEmulatorMessage(type: _type, debugPort: _debugPort),
        StartEmulatorMessageSerializer(),
      );
    }
  }

  void kill() {
    if (_isEmulatorRunning) {
      _fromEmulatorSub?.cancel();
      _fromEmulatorSub = null;
      killEmulator();
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  void updateHardwareDeviceType(HardwareDeviceType type) {
    if (type != _type) {
      _type = type;
      kill();
      run();
    }
  }

  Future<SendPort> _initIsolate() async {
    final Completer<SendPort> completer = Completer<SendPort>();
    final ReceivePort fromEmulatorPort = ReceivePort();

    _fromEmulatorSub = fromEmulatorPort.listen((dynamic data) {
      if (data is SendPort) {
        completer.complete(data);
      } else {
        assert(data is Uint8List);
        _messageHandler(data as Uint8List);
      }
    });

    _isolate = await Isolate.spawn(
      runEmulator,
      fromEmulatorPort.sendPort,
      debugName: 'Emulator',
    );

    return completer.future;
  }

  void _send<T>(T message, EmulatorMessageSerializer<T> serializer) {
    if (_isEmulatorRunning) {
      _toEmulatorPort!.send(serializer.serialize(message));
    }
  }

  void sendKeyDown(String keyName) {
    _send(
      KeyEventMessage(keyName: keyName, isDown: true),
      KeyEventMessageSerializer(),
    );
  }

  void sendKeyUp(String keyName) {
    _send(
      KeyEventMessage(keyName: keyName, isDown: false),
      KeyEventMessageSerializer(),
    );
  }

  void _messageHandler(Uint8List data) {
    final EmulatorMessageId messageId = EmulatorMessageId.values[data[0]];

    switch (messageId) {
      case EmulatorMessageId.isDebugClientConnected:
        final IsDebugClientConnectedMessage message =
            IsDebugClientConnectedMessageSerializer().deserialize(data);
        isDebugClientConnected = message.status;
      case EmulatorMessageId.lcdEvent:
        final LcdEvent event = LcdEventSerializer().deserialize(data);
        _outEventCtrl.add(event);
      default:
        throw Exception('Unknown message: $messageId');
    }
  }
}
