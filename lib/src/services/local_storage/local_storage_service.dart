import 'package:shared_preferences/shared_preferences.dart';

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
}
