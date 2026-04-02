import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/key_color_model.dart';

void main() {
  group(ColorModel, () {
    test('fromJson parses hex color strings', () {
      final ColorModel model = ColorModel.fromJson(<String, dynamic>{
        'background': 'FF0000FF',
        'border': '00FF00FF',
        'color': '0000FFFF',
      });

      expect(model.background, equals(0xFF0000FF));
      expect(model.border, equals(0x00FF00FF));
      expect(model.color, equals(0x0000FFFF));
    });

    test('fromJson throws for missing required field', () {
      expect(
        () => ColorModel.fromJson(<String, dynamic>{
          'background': 'FF0000FF',
          'border': '00FF00FF',
        }),
        throwsA(anything),
      );
    });
  });
}
