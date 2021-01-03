import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories.dart';

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

  Future<bool> setDebugPort(int port) {
    return _sharedPreferences.setInt('debug_port', port);
  }

  int getDebugPort(int defaultPort) {
    try {
      return _sharedPreferences.getInt('debug_port') ?? defaultPort;
    } catch (_) {
      return defaultPort;
    }
  }
}
