import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:roms/roms.dart';
import 'package:test/test.dart';

void main() {
  group('Roms', () {
    test('Should fail for unavailable ROMs', () {
      expect(() => ROM(const ROMType.a01()), throwsException);
      expect(() => ROM(const ROMType.a04()), throwsException);
    });

    test('Should return a valid A03 ROM', () {
      final ROM rom = ROM(const ROMType.a03());

      expect(rom.type, equals(const ROMType.a03()));
      expect(rom.bytes.length, equals(16 * 1024));
      expect(
        sha1.convert(rom.bytes).toString(),
        equals('4bf748ba4d7c2b7cd7da7f3fdefcdd2e4cd41c4e'),
      );

      expect(_romType(rom.bytes), equals(const ROMType.a03()));
    });

    test('available getter should return the available ROM-types', () {
      expect(ROM.available, equals(<ROMType>[const ROMType.a03()]));
    });
  });
}

ROMType _romType(Uint8List bytes) {
  final int marker1 = bytes[0x443];
  final int marker2 = bytes[0x5BD];

  if (marker1 == 56 && marker2 == 129) return const ROMType.a01();
  if (marker1 == 59 && marker2 == 129) return const ROMType.a03();
  if (marker1 == 59 && marker2 == 74) return const ROMType.a04();

  throw Exception('Unknown ROM');
}
