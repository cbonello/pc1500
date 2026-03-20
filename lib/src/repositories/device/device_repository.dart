import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pc1500/src/repositories/repositories.dart';

/// Maps the app-level [DeviceType] to the emulator's [HardwareDeviceType].
///
/// [DeviceType.pc2] is not yet supported and falls back to
/// [HardwareDeviceType.pc1500].
HardwareDeviceType _getHardwareDevice(DeviceType type) => switch (type) {
  DeviceType.pc1500A => HardwareDeviceType.pc1500A,
  DeviceType.pc1500 || DeviceType.pc2 => HardwareDeviceType.pc1500,
};

/// Provides and manages the [Device] (emulator) lifecycle.
final ChangeNotifierProvider<DeviceRepository> deviceRepositoryProvider =
    ChangeNotifierProvider<DeviceRepository>((Ref ref) {
      final DeviceRepository repository = DeviceRepository(ref: ref);
      ref.onDispose(() => repository.device.dispose());

      return repository;
    });

/// Repository that owns the emulator [Device] and handles hardware type
/// changes.
class DeviceRepository with ChangeNotifier {
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
       device = Device(type: _getHardwareDevice(type), debugPort: debugPort) {
    // Fire-and-forget: the isolate spawns asynchronously. Key events sent
    // before it's ready are silently dropped (Device._send checks
    // _isEmulatorRunning).
    device.run();
  }

  final Ref _ref;
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
}
