import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/key_label_model.dart';

void main() {
  group(KeyLabelModel, () {
    test('fromJson creates text label', () {
      final label = KeyLabelModel.fromJson(<String, dynamic>{
        'type': 'text',
        'value': 'SHIFT',
      });

      expect(label, isA<KeyLabelModelText>());
      expect(label.value, equals('SHIFT'));
    });

    test('fromJson creates icon label', () {
      final label = KeyLabelModel.fromJson(<String, dynamic>{
        'type': 'icon',
        'value': 'up',
      });

      expect(label, isA<KeyLabelModelIcon>());
      expect(label.value, equals('up'));
    });

    test('fromJson throws for unknown type', () {
      expect(
        () => KeyLabelModel.fromJson(<String, dynamic>{
          'type': 'unknown',
          'value': 'x',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('when dispatches to text callback', () {
      const label = KeyLabelModelText('ABC');

      final String result = label.when(
        text: (String v) => 'text:$v',
        icon: (String v) => 'icon:$v',
      );

      expect(result, equals('text:ABC'));
    });

    test('when dispatches to icon callback', () {
      const label = KeyLabelModelIcon('left');

      final result = label.when(
        text: (String v) => 'text:$v',
        icon: (String v) => 'icon:$v',
      );

      expect(result, equals('icon:left'));
    });
  });
}
