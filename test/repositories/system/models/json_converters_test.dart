import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/json_converters.dart';

void main() {
  group('intToDouble()', () {
    test('converts int to double', () {
      expect(intToDouble(42), equals(42.0));
      expect(intToDouble(42), isA<double>());
    });

    test('converts zero', () {
      expect(intToDouble(0), equals(0.0));
    });

    test('converts negative', () {
      expect(intToDouble(-10), equals(-10.0));
    });
  });

  group('colorToInt()', () {
    test('parses hex color string', () {
      expect(colorToInt('FF8800FF'), equals(0xFF8800FF));
    });

    test('parses black', () {
      expect(colorToInt('00000000'), equals(0));
    });

    test('parses white with full alpha', () {
      expect(colorToInt('FFFFFFFF'), equals(0xFFFFFFFF));
    });

    test('is case insensitive', () {
      expect(colorToInt('ff8800ff'), equals(0xFF8800FF));
    });
  });
}
