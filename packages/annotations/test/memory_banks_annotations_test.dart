import 'package:annotations/src/models/models.dart';
import 'package:test/test.dart';

import 'data/ce150_version_1_annotations.dart' as ce150;
import 'data/me0_ram_annotations.dart' as ram;
import 'data/pc1500_a03_annotations.dart' as rom;

void main() {
  group('MemoryBanksAnnotations', () {
    test('should load annotations successfully', () {
      expect(
        MemoryBanksAnnotations.fromAnnotations(
          <String>[ce150.json, ram.json, rom.json],
        ),
        equals(const TypeMatcher<MemoryBanksAnnotations>()),
      );
    });

    test('isAnnotated() should return the expected result', () {
      final MemoryBanksAnnotations annotations =
          MemoryBanksAnnotations.fromAnnotations(
        const <String>[ram.json],
      );

      expect(annotations.isAnnotated(0x7B0A), isTrue);
      expect(annotations.isAnnotated(0x7B0D), isFalse);
    });

    test('getAnnotationFromAddress() should return the expected result', () {
      final MemoryBanksAnnotations annotations =
          MemoryBanksAnnotations.fromAnnotations(
        const <String>[ram.json],
      );

      expect(annotations.getAnnotationFromAddress(0x7B0A), isNotNull);
      expect(annotations.getAnnotationFromAddress(0x7B0D), isNull);
    });

    test('isSymbolDefined() should return the expected result', () {
      final MemoryBanksAnnotations annotations =
          MemoryBanksAnnotations.fromAnnotations(
        const <String>[ram.json],
      );

      expect(annotations.isSymbolDefined(0, 'LCDSYM2'), isTrue);
      expect(annotations.isSymbolDefined(0, 'LCDSYM'), isFalse);
    });

    test('getAnnotationFromSymbol() should return the expected result', () {
      final MemoryBanksAnnotations annotations =
          MemoryBanksAnnotations.fromAnnotations(
        const <String>[ram.json],
      );

      expect(annotations.getAnnotationFromSymbol(0, 'LCDSYM2'), isNotNull);
      expect(annotations.getAnnotationFromSymbol(0, 'LCDSYM'), isNull);
    });
  });
}
