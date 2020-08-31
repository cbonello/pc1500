import 'package:annotations/annotations.dart';
import 'package:test/test.dart';

import 'data/ce150_version_1_annotations.dart' as ce150;
import 'data/me0_ram_annotations.dart' as ram;
import 'data/pc1500_a03_annotations.dart' as rom;

void main() {
  group('MemoryBanksAnnotations', () {
    test(
      'should create an instance of MemoryBanksAnnotations successfully',
      () {
        expect(
          MemoryBanksAnnotations(),
          equals(const TypeMatcher<MemoryBanksAnnotations>()),
        );
      },
    );

    group('merge()', () {
      test(
        'should raise an AnnotationsError if the memory areas cannot be merged',
        () {
          expect(
            () => MemoryBanksAnnotations()
              ..merge(
                <String>[ce150.json, ce150.json],
              ),
            throwsA(const TypeMatcher<AnnotationsError>()),
          );
        },
      );

      test('should merge annotations successfully (in any order)', () {
        MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
          ..merge(
            <String>[ce150.json, ram.json, rom.json],
          );
        expect(annotations.banks[0].length, equals(838));
        expect(annotations.banks[1].length, isZero);

        annotations = MemoryBanksAnnotations()
          ..merge(<String>[ce150.json])
          ..merge(<String>[ram.json])
          ..merge(<String>[rom.json]);
        expect(annotations.banks[0].length, equals(838));
        expect(annotations.banks[1].length, isZero);

        annotations = MemoryBanksAnnotations()
          ..merge(<String>[ce150.json])
          ..merge(<String>[ram.json, rom.json]);
        expect(annotations.banks[0].length, equals(838));
        expect(annotations.banks[1].length, isZero);
      });
    });

    test('isAnnotated() should return the expected result', () {
      final MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
        ..merge(<String>[ram.json]);

      expect(annotations.isAnnotated(0x7B0A), isTrue);
      expect(annotations.isAnnotated(0x7B0D), isFalse);
    });

    test('getAnnotationFromAddress() should return the expected result', () {
      final MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
        ..merge(<String>[ram.json]);

      expect(annotations.getAnnotationFromAddress(0x7B0A), isNotNull);
      expect(annotations.getAnnotationFromAddress(0x7B0D), isNull);
    });

    test('isSymbolDefined() should return the expected result', () {
      final MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
        ..merge(<String>[ram.json]);

      expect(annotations.isSymbolDefined(0, 'LCDSYM2'), isTrue);
      expect(annotations.isSymbolDefined(0, 'LCDSYM'), isFalse);
    });

    test('getAnnotationFromSymbol() should return the expected result', () {
      final MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
        ..merge(<String>[ram.json]);

      expect(annotations.getAnnotationFromSymbol(0, 'LCDSYM2'), isNotNull);
      expect(annotations.getAnnotationFromSymbol(0, 'LCDSYM'), isNull);
    });
  });
}
