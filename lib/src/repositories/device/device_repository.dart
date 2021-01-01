import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repositories.dart';

final ChangeNotifierProvider<DeviceRepository> deviceRepositoryProvider =
    ChangeNotifierProvider<DeviceRepository>(
  (ProviderReference ref) {
    final DeviceTypeRepository deviceTypeRepository =
        ref.read(deviceTypeRepositoryProvider);
    final DebugPortRepository debugPortRepository =
        ref.read(debugPortRepositoryProvider);
    final DeviceRepository repository = DeviceRepository(
      type: deviceTypeRepository.deviceType,
      debugPort: debugPortRepository.debugPort,
    );
    return repository;
  },
);

class DeviceRepository with ChangeNotifier {
  DeviceRepository({@required DeviceType type, @required this.debugPort})
      : assert(type != null),
        _type = type,
        assert(debugPort != null),
        device = Device(type: type, debugPort: debugPort)..init();

  DeviceType _type;
  final int debugPort;
  final Device device;

  DeviceType get type => _type;

  set type(DeviceType newType) {
    if (_type != newType) {
      _type = newType;
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
