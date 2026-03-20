import 'dart:async';
import 'dart:isolate';

import 'package:device/src/emulator_isolate/emulator_frontend.dart';
import 'package:device/src/messages.dart';
import 'package:lcd/lcd.dart';

/// Hardware model variants.
enum HardwareDeviceType { pc1500, pc1500A }

/// Main-isolate handle to the PC-1500 emulator.
///
/// Manages the emulator isolate lifecycle, forwards key events, and
/// exposes an LCD event stream for the UI to render.
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

  /// The current hardware model.
  HardwareDeviceType get hardwareDeviceType => _type;

  /// Changes the hardware model, restarting the emulator if needed.
  ///
  /// Returns a [Future] that completes when the new emulator is ready.
  Future<void> updateHardwareDeviceType(HardwareDeviceType newType) async {
    if (newType != _type) {
      _type = newType;
      kill();
      await run();
    }
  }

  /// Stream of LCD display events from the emulator.
  Stream<LcdEvent> get lcdEvents => _outEventCtrl.stream;

  bool get _isEmulatorRunning => _isolate != null;

  /// Spawns the emulator isolate and sends the start configuration.
  ///
  /// Does nothing if the emulator is already running.
  Future<void> run() async {
    if (!_isEmulatorRunning) {
      _toEmulatorPort = await _initIsolate();
      _toEmulatorPort!.send(
        StartEmulatorMsg(type: _type, debugPort: _debugPort),
      );
    }
  }

  /// Terminates the emulator isolate and cleans up resources.
  void kill() {
    if (_isEmulatorRunning) {
      _fromEmulatorSub?.cancel();
      _fromEmulatorSub = null;
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
      _toEmulatorPort = null;
    }
  }

  /// Releases all resources. Call when the [Device] is no longer needed.
  void dispose() {
    kill();
    _outEventCtrl.close();
  }

  Future<SendPort> _initIsolate() async {
    final Completer<SendPort> completer = Completer<SendPort>();
    final ReceivePort fromEmulatorPort = ReceivePort();

    _fromEmulatorSub = fromEmulatorPort.listen((dynamic data) {
      if (data is SendPort) {
        completer.complete(data);
      } else {
        _messageHandler(data);
      }
    });

    _isolate = await Isolate.spawn(
      runEmulator,
      fromEmulatorPort.sendPort,
      debugName: 'Emulator',
    );

    return completer.future;
  }

  /// Sends a key-down event to the emulator.
  void sendKeyDown(String keyName) {
    if (_isEmulatorRunning) {
      _toEmulatorPort!.send(KeyDownMsg(keyName));
    }
  }

  /// Sends a key-up event to the emulator.
  void sendKeyUp(String keyName) {
    if (_isEmulatorRunning) {
      _toEmulatorPort!.send(KeyUpMsg(keyName));
    }
  }

  void _messageHandler(dynamic data) {
    switch (data) {
      case LcdEventMsg(:final event):
        _outEventCtrl.add(event);
      case DebugClientStatusMsg(:final connected):
        isDebugClientConnected = connected;
      default:
        assert(() {
          // ignore: avoid_print
          print('Device: unexpected message ${data.runtimeType}');
          return true;
        }());
    }
  }
}
