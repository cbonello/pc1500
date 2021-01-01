import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:lcd/lcd.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'emulator_isolate/emulator_frontend.dart';
import 'messages/messages.dart';
import 'messages/messages_base.dart';

enum DeviceType { pc1500, pc1500A, pc2 }

class Device {
  Device({@required DeviceType type, @required int debugPort})
      : assert(type != null),
        _type = type,
        assert(debugPort != null),
        _debugPort = debugPort,
        _outEventCtrl = BehaviorSubject<LcdEvent>(),
        isDebuggerConnected = false;

  bool isDebuggerConnected;

  final DeviceType _type;
  final int _debugPort;
  final BehaviorSubject<LcdEvent> _outEventCtrl;
  SendPort _toEmulatorPort;
  StreamSubscription<dynamic> _fromEmulatorSub;

  bool get _isEmulatorRunning => _toEmulatorPort != null;

  Stream<LcdEvent> get lcdEvents => _outEventCtrl.stream;

  Future<void> init() async {
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
      case EmulatorMessageId.isDebuggerConnected:
        final IsDebuggerConnectedMessage message =
            IsDebuggerConnectedMessageSerializer().deserialize(data);
        isDebuggerConnected = message.status;
        print('STATUS $isDebuggerConnected');
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
