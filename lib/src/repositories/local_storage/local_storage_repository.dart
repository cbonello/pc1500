import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Provider<LocalStorageRepository> localStorageRepositoryProvider =
    Provider<LocalStorageRepository>(
  (ProviderReference ref) => throw UnimplementedError(),
);

class LocalStorageRepository {
  LocalStorageRepository({@required SharedPreferences sharedPreferences})
      : assert(sharedPreferences != null),
        _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  Future<bool> setDeviceType(DeviceType type) {
    return _sharedPreferences.setInt('device_type', type.index);
  }

  DeviceType getDeviceType() {
    try {
      final int indexType =
          _sharedPreferences.getInt('device_type') ?? DeviceType.pc1500A.index;
      return DeviceType.values[indexType];
    } catch (_) {
      return DeviceType.pc1500A;
    }
  }
}

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
