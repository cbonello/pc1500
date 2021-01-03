import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/systems_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemsRepository', () {
    test('is created successfully', () async {
      final SystemsRepository systemsRepository =
          await SystemsRepository.getInstance();
      expect(systemsRepository.getSkin(DeviceType.pc1500A), isNotNull);
      expect(
        systemsRepository.skinExistsForDevice(DeviceType.pc1500A),
        isTrue,
      );
      expect(systemsRepository.getSkin(DeviceType.pc2), isNotNull);
      expect(systemsRepository.skinExistsForDevice(DeviceType.pc2), isTrue);
    });
  });
}
