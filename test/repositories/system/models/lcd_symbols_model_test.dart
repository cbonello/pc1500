import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/lcd_symbols_model.dart';

void main() {
  group(LcdSymbolsModel, () {
    test('fromJson parses all symbol positions', () {
      final model = LcdSymbolsModel.fromJson(<String, dynamic>{
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
      });

      expect(model.busy, equals(1.0));
      expect(model.shift, equals(2.0));
      expect(model.small, equals(3.0));
      expect(model.def, equals(4.0));
      expect(model.one, equals(5.0));
      expect(model.two, equals(6.0));
      expect(model.three, equals(7.0));
      expect(model.de, equals(8.0));
      expect(model.g, equals(9.0));
      expect(model.rad, equals(10.0));
      expect(model.run, equals(11.0));
      expect(model.pro, equals(12.0));
      expect(model.reserve, equals(13.0));
    });

    test('fromJson uses numeric JSON keys for I/II/III', () {
      // Verifies the @JsonKey(name: '1') / '2' / '3' annotations work.
      final model = LcdSymbolsModel.fromJson(<String, dynamic>{
        'busy': 0.0,
        'shift': 0.0,
        'small': 0.0,
        'def': 0.0,
        '1': 100.0,
        '2': 200.0,
        '3': 300.0,
        'de': 0.0,
        'g': 0.0,
        'rad': 0.0,
        'run': 0.0,
        'pro': 0.0,
        'reserve': 0.0,
      });

      expect(model.one, equals(100.0));
      expect(model.two, equals(200.0));
      expect(model.three, equals(300.0));
    });

    test('fromJson throws for missing required field', () {
      expect(
        () => LcdSymbolsModel.fromJson(<String, dynamic>{
          'busy': 1.0,
          'shift': 2.0,
          // missing most fields
        }),
        throwsA(anything),
      );
    });
  });
}
