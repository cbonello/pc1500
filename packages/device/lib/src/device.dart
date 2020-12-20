import 'dart:async';
import 'dart:isolate';

import 'package:meta/meta.dart';

import 'emulator_isolate/emulator.dart';

abstract class IsolateBase {
  IsolateBase({@required this.debugPort}) : assert(debugPort != null);

  final int debugPort;

  void init(SendPort isolateToMainStream);

  bool isDebugClientConnected();
}

class Device {
  Device({@required int debugPort})
      : assert(debugPort != null),
        _debugPort = debugPort;

  final int _debugPort;
  SendPort _toEmulatorPort;
  StreamSubscription<dynamic> _fromEmulatorSub;

  bool get _isEmulatorRunning => _toEmulatorPort != null;

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
        print('[isolateToMainStream] $data');
      }
    });

    await Isolate.spawn(
      emulatorMain,
      fromEmulatorPort.sendPort,
      debugName: 'Emulator',
    );

    return completer.future;
  }

  void dispose() {
    _fromEmulatorSub?.cancel();
  }
}
