import 'package:shared_preferences/shared_preferences.dart';
import 'package:system/system.dart';

import 'local_storage_service_base.dart';

class LocalStorageService implements LocalStorageServiceBase {
  static LocalStorageService _instance;
  static SharedPreferences _preferences;

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance;
  }

  @override
  Future<bool> setDebugPort(int port) {
    return _preferences.setInt('debug_port', port);
  }

  @override
  int getDebugPort() {
    try {
      return _preferences.getInt('debug_port') ?? 5600;
    } catch (_) {
      return 5600;
    }
  }

  @override
  Future<bool> setDeviceType(DeviceType type) {
    return _preferences.setInt('device_type', type.index);
  }

  @override
  DeviceType getDeviceType() {
    try {
      final int indexType =
          _preferences.getInt('device_type') ?? DeviceType.pc2.index;
      return DeviceType.values[indexType];
    } catch (_) {
      return DeviceType.pc2;
    }
  }
}
