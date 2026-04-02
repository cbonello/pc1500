import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/lcd_margin_model.dart';

void main() {
  group(LcdMarginModel, () {
    test('fromJson parses and converts int to double', () {
      final model = LcdMarginModel.fromJson(<String, dynamic>{
        'left': 10,
        'top': 20,
        'right': 30,
        'bottom': 40,
      });

      expect(model.left, equals(10.0));
      expect(model.top, equals(20.0));
      expect(model.right, equals(30.0));
      expect(model.bottom, equals(40.0));
      expect(model.left, isA<double>());
    });

    test('fromJson throws for missing required field', () {
      expect(
        () => LcdMarginModel.fromJson(<String, dynamic>{'left': 10, 'top': 20}),
        throwsA(anything),
      );
    });
  });
}
