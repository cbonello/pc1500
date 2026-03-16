import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pc1500/src/repositories/repositories.dart';

HardwareDeviceType _getHardwareDevice(DeviceType type) =>
    type == DeviceType.pc1500A
    ? HardwareDeviceType.pc1500A
    : HardwareDeviceType.pc1500;

final ChangeNotifierProvider<DeviceRepository> deviceRepositoryProvider =
    ChangeNotifierProvider<DeviceRepository>((Ref ref) {
      final DeviceRepository repository = DeviceRepository(ref: ref);
      ref.onDispose(() => repository.device.kill());

      return repository;
    });

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
       device = Device(type: _getHardwareDevice(type), debugPort: debugPort)
         ..run();

  final Ref _ref;
  DeviceType _type;
  final int debugPort;
  final Device device;

  DeviceType get type => _type;

  set type(DeviceType newType) {
    if (_type != newType) {
      _type = _ref.read(deviceTypeRepositoryProvider).deviceType = newType;
      device.updateHardwareDeviceType(_getHardwareDevice(newType));
      notifyListeners();
    }
  }

  bool canSafelySwitchDevices(DeviceType newType) {
    if (_type == DeviceType.pc1500A || newType == DeviceType.pc1500A) {
      return false;
    }

    return true;
  }
}
