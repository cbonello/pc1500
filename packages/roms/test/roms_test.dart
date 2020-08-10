import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:roms/roms.dart';
import 'package:test/test.dart';

void main() {
  group('Roms', () {
    test('Should return a valid PC-1500 ROM', () {
      final Uint8List bytes = Roms.pc1500;

      expect(bytes.length, equals(16 * 1024));
      expect(
        sha1.convert(bytes).toString(),
        equals('4bf748ba4d7c2b7cd7da7f3fdefcdd2e4cd41c4e'),
      );
    });
  });
}
