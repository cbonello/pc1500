import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/lcd_pixels_model.dart';

void main() {
  group(LcdPixelsModel, () {
    test('fromJson parses all fields', () {
      final model = LcdPixelsModel.fromJson(<String, dynamic>{
        'top': 1.5,
        'width': 2.0,
        'height': 3.0,
        'gap': 0.5,
      });

      expect(model.top, equals(1.5));
      expect(model.width, equals(2.0));
      expect(model.height, equals(3.0));
      expect(model.gap, equals(0.5));
    });

    test('fromJson throws for missing required field', () {
      expect(
        () => LcdPixelsModel.fromJson(<String, dynamic>{
          'top': 1.5,
          'width': 2.0,
        }),
        throwsA(anything),
      );
    });
  });
}
