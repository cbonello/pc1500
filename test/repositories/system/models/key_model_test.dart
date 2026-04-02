import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/key_label_model.dart';
import 'package:pc1500/src/repositories/systems/models/key_model.dart';

void main() {
  group(KeyModel, () {
    test('fromJson parses text label key', () {
      final model = KeyModel.fromJson(<String, dynamic>{
        'label': <String, dynamic>{'type': 'text', 'value': 'SHIFT'},
        'color': 'gray',
        'font-size': 14,
        'top': 100,
        'left': 200,
        'width': 50,
        'height': 30,
      });

      expect(model.label, isA<KeyLabelModelText>());
      expect(model.label.value, equals('SHIFT'));
      expect(model.color, equals('gray'));
      expect(model.fontSize, equals(14.0));
      expect(model.top, equals(100.0));
      expect(model.left, equals(200.0));
      expect(model.width, equals(50.0));
      expect(model.height, equals(30.0));
    });

    test('fromJson parses icon label key', () {
      final KeyModel model = KeyModel.fromJson(<String, dynamic>{
        'label': <String, dynamic>{'type': 'icon', 'value': 'up'},
        'color': 'dark',
        'font-size': 16,
        'top': 50,
        'left': 60,
        'width': 40,
        'height': 40,
      });

      expect(model.label, isA<KeyLabelModelIcon>());
      expect(model.label.value, equals('up'));
    });

    test('fromJson converts int coordinates to double', () {
      final KeyModel model = KeyModel.fromJson(<String, dynamic>{
        'label': <String, dynamic>{'type': 'text', 'value': 'A'},
        'color': 'white',
        'font-size': 12,
        'top': 10,
        'left': 20,
        'width': 30,
        'height': 40,
      });

      expect(model.top, isA<double>());
      expect(model.left, isA<double>());
      expect(model.width, isA<double>());
      expect(model.height, isA<double>());
      expect(model.fontSize, isA<double>());
    });

    test('fromJson throws for missing required field', () {
      expect(
        () => KeyModel.fromJson(<String, dynamic>{
          'label': <String, dynamic>{'type': 'text', 'value': 'A'},
          'color': 'white',
          // missing font-size, top, left, width, height
        }),
        throwsA(anything),
      );
    });
  });
}
