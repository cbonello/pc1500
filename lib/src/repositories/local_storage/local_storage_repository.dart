import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc1500/src/repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Must be overridden with a real instance in [ProviderScope.overrides].
final Provider<LocalStorageRepository> localStorageRepositoryProvider =
    Provider<LocalStorageRepository>(
      (Ref ref) => throw StateError(
        'localStorageRepositoryProvider must be overridden with a '
        'LocalStorageRepository instance in ProviderScope.overrides',
      ),
    );

/// Thin wrapper around [SharedPreferences] for persisting user settings.
class LocalStorageRepository {
  LocalStorageRepository({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  static const String _deviceTypeKey = 'device_type';
  static const String _debugPortKey = 'debug_port';

  /// Persists the selected [DeviceType].
  Future<bool> setDeviceType(DeviceType type) {
    return _sharedPreferences.setInt(_deviceTypeKey, type.index);
  }

  /// Reads the persisted [DeviceType], defaulting to [DeviceType.pc1500].
  DeviceType getDeviceType() {
    final int? index = _sharedPreferences.getInt(_deviceTypeKey);
    if (index != null && index >= 0 && index < DeviceType.values.length) {
      return DeviceType.values[index];
    }

    return DeviceType.pc1500;
  }

  /// Persists the debug server port.
  Future<bool> setDebugPort(int port) {
    return _sharedPreferences.setInt(_debugPortKey, port);
  }

  /// Reads the persisted debug port, defaulting to [defaultPort].
  int getDebugPort(int defaultPort) {
    return _sharedPreferences.getInt(_debugPortKey) ?? defaultPort;
  }
}
