import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repositories.dart';

final Provider<DeviceRepository> deviceRepositoryProvider =
    Provider<DeviceRepository>(
  (ProviderReference ref) {
    final DeviceTypeRepository deviceTypeRepository =
        ref.read(deviceTypeRepositoryProvider);
    final DebugPortRepository debugPortRepository =
        ref.read(debugPortRepositoryProvider);

    return DeviceRepository(
      type: deviceTypeRepository.deviceType,
      debugPort: debugPortRepository.debugPort,
    );
  },
);

class DeviceRepository {
  DeviceRepository({@required this.type, @required this.debugPort})
      : assert(type != null),
        assert(debugPort != null),
        device = Device(type: type, debugPort: debugPort)..init();

  final DeviceType type;
  final int debugPort;
  final Device device;

  Future<void> updateDeviceType(DeviceType type) {
    return Future<void>.value();
  }
}
