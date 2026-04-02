import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/local_storage/local_storage_repository.dart';
import 'package:pc1500/src/repositories/systems/systems_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<LocalStorageRepository> createRepo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return LocalStorageRepository(sharedPreferences: prefs);
  }

  group(LocalStorageRepository, () {
    group('deviceType', () {
      test('defaults to pc1500 when no value stored', () async {
        repo = await createRepo();

        expect(repo.getDeviceType(), equals(DeviceType.pc1500));
      });

      test('persists and retrieves device type', () async {
        repo = await createRepo();

        await repo.setDeviceType(DeviceType.pc1500A);
        expect(repo.getDeviceType(), equals(DeviceType.pc1500A));

        await repo.setDeviceType(DeviceType.pc2);
        expect(repo.getDeviceType(), equals(DeviceType.pc2));
      });

      test('returns default for out-of-range index', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'device_type': 999,
        });
        repo = await createRepo();

        expect(repo.getDeviceType(), equals(DeviceType.pc1500));
      });

      test('returns default for negative index', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'device_type': -1,
        });
        repo = await createRepo();

        expect(repo.getDeviceType(), equals(DeviceType.pc1500));
      });
    });

    group('debugPort', () {
      test('defaults to provided value when no value stored', () async {
        repo = await createRepo();

        expect(repo.getDebugPort(3756), equals(3756));
        expect(repo.getDebugPort(9999), equals(9999));
      });

      test('persists and retrieves debug port', () async {
        repo = await createRepo();

        await repo.setDebugPort(8080);
        expect(repo.getDebugPort(3756), equals(8080));
      });
    });
  });
}
