import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc1500/src/repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Provider<LocalStorageRepository> localStorageRepositoryProvider =
    Provider<LocalStorageRepository>(
      (Ref ref) => throw StateError(
        'localStorageRepositoryProvider must be overridden with a '
        'LocalStorageRepository instance in ProviderScope.overrides',
      ),
    );

class LocalStorageRepository {
  LocalStorageRepository({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

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
