import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pc1500/src/repositories/repositories.dart';

final ChangeNotifierProvider<DeviceTypeRepository>
deviceTypeRepositoryProvider = ChangeNotifierProvider<DeviceTypeRepository>((
  Ref ref,
) {
  final DeviceTypeRepository repository = DeviceTypeRepository(
    localStorageRepository: ref.watch(localStorageRepositoryProvider),
  );

  return repository;
});

class DeviceTypeRepository with ChangeNotifier {
  DeviceTypeRepository({required LocalStorageRepository localStorageRepository})
    : _localStorageRepository = localStorageRepository,
      _deviceType = localStorageRepository.getDeviceType();

  final LocalStorageRepository _localStorageRepository;
  DeviceType _deviceType;

  DeviceType get deviceType => _deviceType;

  set deviceType(DeviceType deviceType) {
    if (deviceType != _deviceType) {
      _localStorageRepository.setDeviceType(deviceType);
      _deviceType = deviceType;
      notifyListeners();
    }
  }
}
