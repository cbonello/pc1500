import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/lcd_model.dart';

Map<String, dynamic> _validLcdJson() => <String, dynamic>{
  'colors': <String, dynamic>{
    'background': 'AABBCCDD',
    'pixel-On': '11223344',
    'pixel-Off': '55667788',
    'symbol-On': '99AABBCC',
    'symbol-Off': 'DDEEFF00',
  },
  'margin': <String, dynamic>{'left': 5, 'top': 6, 'right': 7, 'bottom': 8},
  'symbols': <String, dynamic>{
    'busy': 1.0,
    'shift': 2.0,
    'small': 3.0,
    'def': 4.0,
    '1': 5.0,
    '2': 6.0,
    '3': 7.0,
    'de': 8.0,
    'g': 9.0,
    'rad': 10.0,
    'run': 11.0,
    'pro': 12.0,
    'reserve': 13.0,
  },
  'pixels': <String, dynamic>{
    'top': 1.5,
    'width': 2.0,
    'height': 3.0,
    'gap': 0.5,
  },
  'left': 100,
  'top': 200,
  'width': 600,
  'height': 80,
};

void main() {
  group(LcdModel, () {
    test('fromJson parses complete LCD configuration', () {
      final model = LcdModel.fromJson(_validLcdJson());

      expect(model.left, equals(100.0));
      expect(model.top, equals(200.0));
      expect(model.width, equals(600.0));
      expect(model.height, equals(80.0));

      expect(model.colors.background, equals(0xAABBCCDD));
      expect(model.margin.left, equals(5.0));
      expect(model.symbols.busy, equals(1.0));
      expect(model.pixels.gap, equals(0.5));
    });

    test('fromJson converts int dimensions to double', () {
      final model = LcdModel.fromJson(_validLcdJson());

      expect(model.left, isA<double>());
      expect(model.top, isA<double>());
      expect(model.width, isA<double>());
      expect(model.height, isA<double>());
    });

    test('fromJson throws for missing required field', () {
      final json = _validLcdJson();
      json.remove('colors');

      expect(() => LcdModel.fromJson(json), throwsA(anything));
    });
  });
}
