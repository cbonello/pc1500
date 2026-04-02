import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/systems_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemsRepository', () {
    test('loads all device skins', () async {
      final repo = await SystemsRepository.getInstance();

      for (final DeviceType type in DeviceType.values) {
        expect(repo.skinExistsForDevice(type), isTrue);
        expect(repo.getSkin(type), isNotNull);
      }
    });

    test('getSkin returns distinct skins per device type', () async {
      final repo = await SystemsRepository.getInstance();
      final skin1500 = repo.getSkin(DeviceType.pc1500);
      final skin1500A = repo.getSkin(DeviceType.pc1500A);
      final skinPc2 = repo.getSkin(DeviceType.pc2);

      // Each skin should reference a different image asset.
      expect(skin1500.image, isNot(equals(skin1500A.image)));
      expect(skin1500.image, isNot(equals(skinPc2.image)));
    });

    test('getInstance returns the same instance', () async {
      final repo1 = await SystemsRepository.getInstance();
      final repo2 = await SystemsRepository.getInstance();

      expect(identical(repo1, repo2), isTrue);
    });
  });
}
