import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device/device.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pc1500/src/buzzer.dart';
import 'package:pc1500/src/repositories/repositories.dart';

/// Maps the app-level [DeviceType] to the emulator's [HardwareDeviceType].
///
/// [DeviceType.pc2] is not yet supported and falls back to
/// [HardwareDeviceType.pc1500].
HardwareDeviceType _getHardwareDevice(DeviceType type) => switch (type) {
  DeviceType.pc1500A => HardwareDeviceType.pc1500A,
  DeviceType.pc1500 || DeviceType.pc2 => HardwareDeviceType.pc1500,
};

/// Maximum state file size (1 MB). Files larger than this are rejected
/// to guard against corrupt or maliciously crafted data.
const int _maxStateFileSize = 1024 * 1024;

/// Returns the state file path for the given device type.
Future<File> _stateFile(DeviceType type) async {
  final Directory dir = await getApplicationSupportDirectory();
  return File('${dir.path}/${type.name}_state.json');
}

/// Provides and manages the [Device] (emulator) lifecycle.
final ChangeNotifierProvider<DeviceRepository> deviceRepositoryProvider =
    ChangeNotifierProvider<DeviceRepository>((Ref ref) {
      final DeviceRepository repository = DeviceRepository(ref: ref);
      ref.onDispose(() {
        repository._buzzerSub?.cancel();
        repository._powerStateSub?.cancel();
        repository._buzzer.dispose();
        repository.device.dispose();
        WidgetsBinding.instance.removeObserver(repository);
      });

      return repository;
    });

/// Repository that owns the emulator [Device] and handles hardware type
/// changes, state persistence, and app lifecycle events.
class DeviceRepository with ChangeNotifier, WidgetsBindingObserver {
  factory DeviceRepository({required Ref ref}) {
    return DeviceRepository._(
      ref: ref,
      type: ref.read(deviceTypeRepositoryProvider).deviceType,
      debugPort: ref.read(debugPortRepositoryProvider).debugPort,
    );
  }

  DeviceRepository._({
    required Ref ref,
    required DeviceType type,
    required this.debugPort,
  }) : _ref = ref,
       _type = type,
       _buzzer = Buzzer(),
       device = Device(type: _getHardwareDevice(type), debugPort: debugPort) {
    _buzzerSub = _buzzer.listen(device.buzzerEvents);
    _powerStateSub = device.powerState.listen(_onPowerStateChanged);
    WidgetsBinding.instance.addObserver(this);
    // Fire-and-forget: the isolate spawns asynchronously. Key events sent
    // before it's ready are silently dropped (Device._send checks
    // _isEmulatorRunning).
    _initDevice();
  }

  final Ref _ref;
  final Buzzer _buzzer;
  // Cancelled in the ref.onDispose callback in deviceRepositoryProvider.
  // ignore: cancel_subscriptions
  StreamSubscription<BuzzerEventMsg>? _buzzerSub;
  // Cancelled in the ref.onDispose callback in deviceRepositoryProvider.
  // ignore: cancel_subscriptions
  StreamSubscription<bool>? _powerStateSub;
  DeviceType _type;

  /// Debug server TCP port.
  final int debugPort;

  /// The emulator instance.
  final Device device;

  /// The current device type.
  DeviceType get type => _type;

  /// Changes the emulated hardware type.
  ///
  /// Persists the selection and restarts the emulator with the new type.
  /// Listeners are notified after the type is updated (the emulator restart
  /// completes asynchronously in the background).
  set type(DeviceType newType) {
    if (_type != newType) {
      _type = _ref.read(deviceTypeRepositoryProvider).deviceType = newType;
      // Fire-and-forget: the emulator restarts asynchronously.
      device.updateHardwareDeviceType(_getHardwareDevice(newType));
      notifyListeners();
    }
  }

  /// Returns whether switching from the current type to [newType] can be done
  /// without losing the user's BASIC program.
  ///
  /// Switching between models with different RAM sizes (e.g. PC-1500 ↔ PC-1500A)
  /// clears the program area. Returns `false` if either the current or target
  /// type is PC-1500A (6KB RAM vs 2KB).
  bool canSafelySwitchDevices(DeviceType newType) {
    if (_type == DeviceType.pc1500A || newType == DeviceType.pc1500A) {
      return false;
    }

    return true;
  }

  // ── State persistence ──────────────────────────────────────────────

  /// Starts the device and attempts to restore saved state.
  Future<void> _initDevice() async {
    await device.run();
    await _tryRestore();
  }

  /// Attempts to restore emulator state from disk.
  Future<void> _tryRestore() async {
    try {
      final File file = await _stateFile(_type);
      if (!file.existsSync()) return;

      final int size = file.lengthSync();
      if (size > _maxStateFileSize) {
        await file.delete();
        return;
      }

      final String json = await file.readAsString();
      final Map<String, dynamic> state =
          jsonDecode(json) as Map<String, dynamic>;

      final bool success = await device.restoreState(state);
      if (!success) {
        await file.delete();
      }
    } on Object catch (e) {
      // Corrupt file, JSON parse error, type cast error, etc.
      // Fall back to cold boot silently.
      assert(() {
        debugPrint('State restore failed: $e');
        return true;
      }());
      try {
        final File file = await _stateFile(_type);
        if (file.existsSync()) await file.delete();
      } on Object catch (_) {}
    }
  }

  /// Saves emulator state to disk.
  Future<void> _saveState() async {
    try {
      final Map<String, dynamic> state = await device.saveState();
      final File file = await _stateFile(_type);
      await file.writeAsString(jsonEncode(state));
    } on Object catch (e) {
      assert(() {
        debugPrint('State save failed: $e');
        return true;
      }());
    }
  }

  /// Called when the emulator power state changes.
  void _onPowerStateChanged(bool isOn) {
    if (!isOn) {
      // Auto-save on power off.
      _saveState();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Save state when app is backgrounded or about to be killed.
      _saveState();
    }
  }
}
