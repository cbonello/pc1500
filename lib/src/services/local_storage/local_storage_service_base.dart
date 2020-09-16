import 'package:system/system.dart';

abstract class LocalStorageServiceBase {
  int getDebugPort();
  Future<bool> setDebugPort(int port);
  Future<bool> setDeviceType(DeviceType type);
  DeviceType getDeviceType();
}
