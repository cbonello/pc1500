import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/lcd_colors_model.dart';

void main() {
  group(LcdColorsModel, () {
    test('fromJson parses all color fields', () {
      final model = LcdColorsModel.fromJson(<String, dynamic>{
        'background': 'AABBCCDD',
        'pixel-On': '11223344',
        'pixel-Off': '55667788',
        'symbol-On': '99AABBCC',
        'symbol-Off': 'DDEEFF00',
      });

      expect(model.background, equals(0xAABBCCDD));
      expect(model.pixelOn, equals(0x11223344));
      expect(model.pixelOff, equals(0x55667788));
      expect(model.symbolOn, equals(0x99AABBCC));
      expect(model.symbolOff, equals(0xDDEEFF00));
    });

    test('fromJson throws for missing required field', () {
      expect(
        () => LcdColorsModel.fromJson(<String, dynamic>{
          'background': 'AABBCCDD',
          'pixel-On': '11223344',
          // missing pixel-Off, symbol-On, symbol-Off
        }),
        throwsA(anything),
      );
    });
  });
}
