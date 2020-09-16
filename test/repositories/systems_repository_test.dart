import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/systems_repository.dart';
import 'package:system/system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemsRepository', () {
    test('Parses pc2.json successfully', () async {
      final SystemsRepository systemsRepository =
          await SystemsRepository.getInstance();
      expect(systemsRepository.getSkin(DeviceType.pc1500), isNull);
      expect(systemsRepository.getSkin(DeviceType.pc1500A), isNull);
      expect(systemsRepository.getSkin(DeviceType.pc2), isNotNull);
    });
  });
}
