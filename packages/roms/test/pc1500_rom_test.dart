import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:roms/roms.dart';
import 'package:test/test.dart';

void main() {
  group('PC1500Rom', () {
    test('Should fail for unavailable ROMs', () {
      expect(() => PC1500Rom(PC1500RomType.a01), throwsException);
      expect(() => PC1500Rom(PC1500RomType.a04), throwsException);
    });

    test('Should return a valid A03 ROM', () {
      final PC1500Rom rom = PC1500Rom(PC1500RomType.a03);

      expect(rom.type, equals(PC1500RomType.a03));
      expect(rom.bytes.length, equals(16 * 1024));
      expect(
        sha1.convert(rom.bytes).toString(),
        equals('4bf748ba4d7c2b7cd7da7f3fdefcdd2e4cd41c4e'),
      );

      expect(_romType(rom.bytes), equals(PC1500RomType.a03));
    });

    test('A03 ROM should be annotated', () {
      final PC1500Rom rom = PC1500Rom(PC1500RomType.a03);

      expect(rom.type, equals(PC1500RomType.a03));
      expect(rom.annotations.length, greaterThan(0));

      final Annotation annotation = rom.annotations.find(0xE000);
      expect(annotation, isNotNull);
      expect(annotation.comment, equals('Reset Subroutine'));
      expect(annotation.tag, isEmpty);
    });

    test('available getter should return the available ROM-types', () {
      expect(PC1500Rom.available, equals(<PC1500RomType>[PC1500RomType.a03]));
    });
  });
}

PC1500RomType _romType(Uint8List bytes) {
  final int marker1 = bytes[0x443];
  final int marker2 = bytes[0x5BD];

  if (marker1 == 56 && marker2 == 129) return PC1500RomType.a01;
  if (marker1 == 59 && marker2 == 129) return PC1500RomType.a03;
  if (marker1 == 59 && marker2 == 74) return PC1500RomType.a04;

  throw Exception('Unknown ROM');
}
