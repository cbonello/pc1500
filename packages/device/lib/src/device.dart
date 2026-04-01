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
      _buzzerEventCtrl = StreamController<BuzzerEventMsg>.broadcast(),
      _powerStateCtrl = StreamController<bool>.broadcast(),
      isDebugClientConnected = false;

  bool isDebugClientConnected;

  HardwareDeviceType _type;
  final int _debugPort;
  final StreamController<LcdEvent> _outEventCtrl;
  final StreamController<BuzzerEventMsg> _buzzerEventCtrl;
  final StreamController<bool> _powerStateCtrl;
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

  /// Stream of buzzer events from the emulator.
  Stream<BuzzerEventMsg> get buzzerEvents => _buzzerEventCtrl.stream;

  bool _isPoweredOn = false;

  /// Whether the emulator is currently powered on.
  bool get isPoweredOn => _isPoweredOn;

  /// Stream of power state changes (true = on, false = off).
  Stream<bool> get powerState => _powerStateCtrl.stream;

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
    _buzzerEventCtrl.close();
    _powerStateCtrl.close();
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

  // ── State persistence ──────────────────────────────────────────────

  Completer<Map<String, dynamic>>? _saveCompleter;
  Completer<RestoreStateResultMsg>? _restoreCompleter;

  /// Requests a state snapshot from the emulator isolate.
  ///
  /// Returns the serializable state map. Times out after 5 seconds.
  Future<Map<String, dynamic>> saveState() {
    if (!_isEmulatorRunning) {
      return Future<Map<String, dynamic>>.error(
        StateError('Emulator is not running'),
      );
    }
    _saveCompleter = Completer<Map<String, dynamic>>();
    _toEmulatorPort!.send(const SaveStateMsg());
    return _saveCompleter!.future.timeout(const Duration(seconds: 5));
  }

  /// Sends a state map to the emulator isolate for restoration.
  ///
  /// Returns `true` on success, `false` on failure. Times out after 5 seconds.
  Future<bool> restoreState(Map<String, dynamic> state) async {
    if (!_isEmulatorRunning) return false;
    _restoreCompleter = Completer<RestoreStateResultMsg>();
    _toEmulatorPort!.send(RestoreStateMsg(state));
    try {
      final RestoreStateResultMsg result =
          await _restoreCompleter!.future.timeout(const Duration(seconds: 5));
      return result.success;
    } on TimeoutException {
      return false;
    }
  }

  void _messageHandler(dynamic data) {
    switch (data) {
      case PowerStateMsg(:final isOn):
        _isPoweredOn = isOn;
        _powerStateCtrl.add(isOn);
      case LcdEventMsg(:final event):
        _outEventCtrl.add(event);
      case BuzzerEventMsg():
        _buzzerEventCtrl.add(data);
      case DebugClientStatusMsg(:final connected):
        isDebugClientConnected = connected;
      case SaveStateResultMsg(:final state):
        _saveCompleter?.complete(state);
        _saveCompleter = null;
      case RestoreStateResultMsg():
        _restoreCompleter?.complete(data);
        _restoreCompleter = null;
      default:
        assert(() {
          // ignore: avoid_print
          print('Device: unexpected message ${data.runtimeType}');
          return true;
        }());
    }
  }
}
