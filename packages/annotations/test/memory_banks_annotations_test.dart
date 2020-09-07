import 'dart:convert';

import 'package:annotations/annotations.dart';
import 'package:test/test.dart';

import 'data/ce150_version_1_annotations.dart' as ce150;
import 'data/me0_ram_annotations.dart' as ram;
import 'data/pc1500_a03_annotations.dart' as rom;

void main() {
  final Map<String, dynamic> jsonCE150 =
      jsonDecode(ce150.str) as Map<String, dynamic>;
  final Map<String, dynamic> jsonRAM =
      jsonDecode(ram.str) as Map<String, dynamic>;
  final Map<String, dynamic> jsonROM =
      jsonDecode(rom.str) as Map<String, dynamic>;

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

    group('load()', () {
      test(
        'should raise an AnnotationsError if the memory areas cannot be loaded',
        () {
          expect(
            () => MemoryBanksAnnotations()..load(jsonCE150)..load(jsonCE150),
            throwsA(const TypeMatcher<AnnotationsError>()),
          );
        },
      );

      test('should load and merge annotations successfully (in any order)', () {
        MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
          ..load(jsonCE150)
          ..load(jsonRAM)
          ..load(jsonROM);
        expect(annotations.banks[0].length, equals(838));
        expect(annotations.banks[1].length, isZero);

        annotations = MemoryBanksAnnotations()
          ..load(jsonRAM)
          ..load(jsonCE150)
          ..load(jsonROM);
        expect(annotations.banks[0].length, equals(838));
        expect(annotations.banks[1].length, isZero);

        annotations = MemoryBanksAnnotations()
          ..load(jsonRAM)
          ..load(jsonROM)
          ..load(jsonCE150);
        expect(annotations.banks[0].length, equals(838));
        expect(annotations.banks[1].length, isZero);
      });
    });

    test('isAnnotated() should return the expected result', () {
      final MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
        ..load(jsonRAM);

      expect(annotations.isAnnotated(0x7B0A), isTrue);
      expect(annotations.isAnnotated(0x7B0D), isFalse);
    });

    test('getAnnotationFromAddress() should return the expected result', () {
      final MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
        ..load(jsonRAM);

      expect(annotations.getAnnotationFromAddress(0x7B0A), isNotNull);
      expect(annotations.getAnnotationFromAddress(0x7B0D), isNull);
    });

    test('isSymbolDefined() should return the expected result', () {
      final MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
        ..load(jsonRAM);

      expect(annotations.isSymbolDefined(0, 'LCDSYM2'), isTrue);
      expect(annotations.isSymbolDefined(0, 'LCDSYM'), isFalse);
    });

    test('getAnnotationFromSymbol() should return the expected result', () {
      final MemoryBanksAnnotations annotations = MemoryBanksAnnotations()
        ..load(jsonRAM);

      expect(annotations.getAnnotationFromSymbol(0, 'LCDSYM2'), isNotNull);
      expect(annotations.getAnnotationFromSymbol(0, 'LCDSYM'), isNull);
    });
  });
}
