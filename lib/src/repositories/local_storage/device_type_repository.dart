import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pc1500/src/repositories/repositories.dart';

/// Provides the persisted device type selection.
final ChangeNotifierProvider<DeviceTypeRepository>
    deviceTypeRepositoryProvider =
    ChangeNotifierProvider<DeviceTypeRepository>((Ref ref) {
      return DeviceTypeRepository(
        localStorageRepository: ref.watch(localStorageRepositoryProvider),
      );
    });

/// Repository for the selected hardware device type.
class DeviceTypeRepository with ChangeNotifier {
  DeviceTypeRepository({required LocalStorageRepository localStorageRepository})
    : _localStorageRepository = localStorageRepository,
      _deviceType = localStorageRepository.getDeviceType();

  final LocalStorageRepository _localStorageRepository;
  DeviceType _deviceType;

  /// The currently selected device type.
  DeviceType get deviceType => _deviceType;

  /// Updates the device type and persists the change.
  set deviceType(DeviceType deviceType) {
    if (deviceType != _deviceType) {
      _localStorageRepository.setDeviceType(deviceType);
      _deviceType = deviceType;
      notifyListeners();
    }
  }
}
