import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:roms/roms.dart';
import 'package:test/test.dart';

void main() {
  group('CE150Rom', () {
    test('Should fail for unavailable ROMs', () {
      expect(() => CE150Rom(CE150RomType.version_0), throwsException);
    });

    test('Should return a valid version #1 ROM', () {
      final CE150Rom rom = CE150Rom(CE150RomType.version_1);

      expect(rom.type, equals(CE150RomType.version_1));
      expect(rom.bytes.length, equals(8 * 1024));
      expect(
        sha1.convert(rom.bytes).toString(),
        equals('a3aa02a641a46c27c0d4c0dc025b0dbe9b5b79c8'),
      );

      expect(_romType(rom.bytes), equals(CE150RomType.version_1));
    });

    test('version #1 ROM should be annotated', () {
      final CE150Rom rom = CE150Rom(CE150RomType.version_1);

      expect(rom.type, equals(CE150RomType.version_1));
      expect(rom.annotations.length, greaterThan(0));

      final Annotation annotation = rom.annotations.find(0xA800);
      expect(annotation, isNotNull);
      expect(
        annotation.comment,
        equals('CE-150 ROM version: 44H = version 0, BEH = version 1'),
      );
      expect(annotation.tag, isEmpty);
    });

    test('available getter should return the available ROM-types', () {
      expect(
          CE150Rom.available, equals(<CE150RomType>[CE150RomType.version_1]));
    });
  });
}

CE150RomType _romType(Uint8List bytes) {
  final int marker = bytes[0x800];

  if (marker == 0x44) return CE150RomType.version_0;
  if (marker == 0xBE) return CE150RomType.version_1;

  throw Exception('Unknown ROM');
}
