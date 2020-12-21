import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:lcd/lcd.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'emulator_isolate/device.dart';
import 'emulator_isolate/emulator.dart';
import 'messages/from_emulator.dart';
import 'messages/message.dart';

abstract class IsolateBase {
  IsolateBase({@required this.debugPort}) : assert(debugPort != null);

  final int debugPort;

  void init(SendPort isolateToMainStream);

  bool isDebugClientConnected();
}

class Device {
  Device({@required DeviceType type, @required int debugPort})
      : assert(type != null),
        _type = type,
        assert(debugPort != null),
        _debugPort = debugPort,
        _outEventCtrl = BehaviorSubject<LcdEvent>();

  final DeviceType _type;
  final int _debugPort;
  final BehaviorSubject<LcdEvent> _outEventCtrl;
  SendPort _toEmulatorPort;
  StreamSubscription<dynamic> _fromEmulatorSub;

  bool get _isEmulatorRunning => _toEmulatorPort != null;

  Stream<LcdEvent> get lcdEvents => _outEventCtrl.stream;

  Future<void> init() async {
    _toEmulatorPort = await _initIsolate();
  }

  void send(Object command) {
    if (_isEmulatorRunning) {
      _toEmulatorPort.send(command);
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
      emulatorMain,
      fromEmulatorPort.sendPort,
      debugName: 'Emulator',
    );

    return completer.future;
  }

  void _messageHandler(Uint8List data) {
    final MessageId messageId = MessageId.values[data[0]];

    switch (messageId) {
      case MessageId.lcdEvent:
        final LcdEventMessage message =
            LcdEventMessageSerializer().deserialize(data);
        _outEventCtrl.add(message.event);
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
