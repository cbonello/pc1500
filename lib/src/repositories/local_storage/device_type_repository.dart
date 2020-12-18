import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/all.dart';

import 'local_storage_repository.dart';

final ChangeNotifierProvider<DeviceTypeRepository>
    deviceTypeRepositoryProvider = ChangeNotifierProvider<DeviceTypeRepository>(
  (ProviderReference ref) {
    final DeviceTypeRepository repository = DeviceTypeRepository(
      localStorageRepository: ref.watch(localStorageRepositoryProvider),
    );
    return repository;
  },
);

class DeviceTypeRepository with ChangeNotifier {
  DeviceTypeRepository({
    @required LocalStorageRepository localStorageRepository,
  })  : assert(localStorageRepository != null),
        _localStorageRepository = localStorageRepository,
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
