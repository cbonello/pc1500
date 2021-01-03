import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repositories.dart';

HardwareDeviceType _getHardwareDevice(DeviceType type) =>
    type == DeviceType.pc1500A
        ? HardwareDeviceType.pc1500A
        : HardwareDeviceType.pc1500;

final ChangeNotifierProvider<DeviceRepository> deviceRepositoryProvider =
    ChangeNotifierProvider<DeviceRepository>(
  (ProviderReference ref) => DeviceRepository(ref: ref),
);

class DeviceRepository with ChangeNotifier {
  factory DeviceRepository({@required ProviderReference ref}) {
    assert(ref != null);
    return DeviceRepository._(
      ref: ref,
      type: ref.read(deviceTypeRepositoryProvider).deviceType,
      debugPort: ref.read(debugPortRepositoryProvider).debugPort,
    );
  }

  DeviceRepository._({
    @required ProviderReference ref,
    @required DeviceType type,
    @required this.debugPort,
  })  : assert(ref != null),
        _ref = ref,
        assert(type != null),
        _type = type,
        assert(debugPort != null),
        device = Device(type: _getHardwareDevice(type), debugPort: debugPort)
          ..init();

  final ProviderReference _ref;
  DeviceType _type;
  final int debugPort;
  final Device device;

  DeviceType get type => _type;

  set type(DeviceType newType) {
    if (_type != newType) {
      _type = _ref.read(deviceTypeRepositoryProvider).deviceType = newType;
      notifyListeners();
    }
  }

  bool canSafelySwitchDevices(DeviceType newType) {
    if (_type == DeviceType.pc1500A || newType == DeviceType.pc1500A) {
      // We are switching from/to devices that are not hardware equivalent.
      return false;
    }
    return true;
  }
}
