import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/local_storage/device_type_repository.dart';
import 'package:pc1500/src/repositories/local_storage/local_storage_repository.dart';
import 'package:pc1500/src/repositories/systems/systems_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageRepository localStorage;
  late DeviceTypeRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    localStorage = LocalStorageRepository(sharedPreferences: prefs);
    repo = DeviceTypeRepository(localStorageRepository: localStorage);
  });

  group(DeviceTypeRepository, () {
    test('initial value comes from local storage', () {
      expect(repo.deviceType, equals(DeviceType.pc1500));
    });

    test('setting device type updates the value', () {
      repo.deviceType = DeviceType.pc1500A;

      expect(repo.deviceType, equals(DeviceType.pc1500A));
    });

    test('setting device type persists to local storage', () {
      repo.deviceType = DeviceType.pc2;

      expect(localStorage.getDeviceType(), equals(DeviceType.pc2));
    });

    test('setting device type notifies listeners', () {
      bool notified = false;
      repo.addListener(() => notified = true);

      repo.deviceType = DeviceType.pc1500A;

      expect(notified, isTrue);
    });

    test('setting same device type does not notify', () {
      bool notified = false;
      repo.addListener(() => notified = true);

      repo.deviceType = DeviceType.pc1500; // same as initial

      expect(notified, isFalse);
    });
  });
}
