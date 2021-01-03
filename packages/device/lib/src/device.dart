import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:lcd/lcd.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'emulator_isolate/emulator_frontend.dart';
import 'messages/messages.dart';
import 'messages/messages_base.dart';

enum HardwareDeviceType { pc1500, pc1500A }

class Device {
  Device({@required HardwareDeviceType type, @required int debugPort})
      : assert(type != null),
        _type = type,
        assert(debugPort != null),
        _debugPort = debugPort,
        _outEventCtrl = BehaviorSubject<LcdEvent>(),
        isDebugClientConnected = false;

  bool isDebugClientConnected;

  final HardwareDeviceType _type;
  final int _debugPort;
  final BehaviorSubject<LcdEvent> _outEventCtrl;
  SendPort _toEmulatorPort;
  StreamSubscription<dynamic> _fromEmulatorSub;

  bool get _isEmulatorRunning => _toEmulatorPort != null;

  Stream<LcdEvent> get lcdEvents => _outEventCtrl.stream;

  Future<void> run() async {
    _toEmulatorPort = await _initIsolate();

    send(
      StartEmulatorMessage(type: _type, debugPort: _debugPort),
      StartEmulatorMessageSerializer(),
    );
  }

  void send<T>(T message, EmulatorMessageSerializer<T> serializer) {
    if (_isEmulatorRunning) {
      _toEmulatorPort.send(serializer.serialize(message));
    }
  }

  Future<SendPort> _initIsolate() async {
    final Completer<SendPort> completer = Completer<SendPort>();
    final ReceivePort fromEmulatorPort = ReceivePort();

    _fromEmulatorSub = fromEmulatorPort.listen((dynamic data) {
      if (data is SendPort) {
        final SendPort toEmulatorPort = data;
        completer.complete(toEmulatorPort);
      } else {
        assert(data is Uint8List);
        _messageHandler(data as Uint8List);
      }
    });

    await Isolate.spawn(
      emulatorLaunch,
      fromEmulatorPort.sendPort,
      debugName: 'Emulator',
    );

    return completer.future;
  }

  void _messageHandler(Uint8List data) {
    final EmulatorMessageId messageId = EmulatorMessageId.values[data[0]];

    switch (messageId) {
      case EmulatorMessageId.isDebugClientConnected:
        final IsDebugClientConnectedMessage message =
            IsDebugClientConnectedMessageSerializer().deserialize(data);
        isDebugClientConnected = message.status;
        print('STATUS $isDebugClientConnected');
        break;
      case EmulatorMessageId.lcdEvent:
        final LcdEvent event = LcdEventSerializer().deserialize(data);
        _outEventCtrl.add(event);
        break;
      default:
        throw Exception();
    }
  }

  void dispose() {
    _outEventCtrl.close();
    _fromEmulatorSub?.cancel();
  }
}
