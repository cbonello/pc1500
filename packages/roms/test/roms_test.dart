import 'dart:typed_data';

import 'package:roms/roms.dart';
import 'package:test/test.dart';

void main() {
  group('Roms', () {
    test('Should return a valid PC-1500 ROM', () {
      final Uint8List data = Roms.pc1500;

      expect(data.length, equals(16 * 1024));
    });

    test('Should return a valid PC-1500A ROM', () {
      final Uint8List data = Roms.pc1500a;

      expect(data.length, equals(16 * 1024));
    });
  });
}
