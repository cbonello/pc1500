import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/local_storage/debug_port_repository.dart';
import 'package:pc1500/src/repositories/local_storage/local_storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageRepository localStorage;
  late DebugPortRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    localStorage = LocalStorageRepository(sharedPreferences: prefs);
    repo = DebugPortRepository(localStorageRepository: localStorage);
  });

  group(DebugPortRepository, () {
    test('initial value is default port 3756', () {
      expect(repo.debugPort, equals(3756));
    });

    test('setting port updates the value', () {
      repo.debugPort = 8080;

      expect(repo.debugPort, equals(8080));
    });

    test('setting port persists to local storage', () {
      repo.debugPort = 9000;

      expect(localStorage.getDebugPort(0), equals(9000));
    });

    test('setting port notifies listeners', () {
      bool notified = false;
      repo.addListener(() => notified = true);

      repo.debugPort = 4000;

      expect(notified, isTrue);
    });

    test('setting same port does not notify', () {
      bool notified = false;
      repo.addListener(() => notified = true);

      repo.debugPort = 3756; // same as default

      expect(notified, isFalse);
    });

    test('rejects negative port', () {
      repo.debugPort = -1;

      expect(repo.debugPort, equals(3756));
    });

    test('rejects port above 65535', () {
      repo.debugPort = 65536;

      expect(repo.debugPort, equals(3756));
    });

    test('accepts edge values 0 and 65535', () {
      repo.debugPort = 0;
      expect(repo.debugPort, equals(0));

      repo.debugPort = 65535;
      expect(repo.debugPort, equals(65535));
    });

    test('resetDebugPort restores default', () {
      repo.debugPort = 9999;
      repo.resetDebugPort();

      expect(repo.debugPort, equals(3756));
    });
  });
}
