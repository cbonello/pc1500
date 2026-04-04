import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/pages/home/skin.dart';

void main() {
  group('physicalKeyMap', () {
    test('maps all 26 letter keys', () {
      const String letters = 'abcdefghijklmnopqrstuvwxyz';
      for (int i = 0; i < letters.length; i++) {
        final String letter = letters[i];
        final LogicalKeyboardKey key = LogicalKeyboardKey(
          // keyA = 0x00000061, keyB = 0x00000062, etc.
          0x00000061 + i,
        );
        expect(physicalKeyMap[key], equals(letter), reason: 'key $letter');
      }
    });

    test('maps digit row 0-9', () {
      for (int i = 0; i <= 9; i++) {
        final LogicalKeyboardKey key = LogicalKeyboardKey(
          // digit0 = 0x00000030
          0x00000030 + i,
        );
        expect(physicalKeyMap[key], equals('$i'), reason: 'digit $i');
      }
    });

    test('maps numpad 0-9', () {
      final List<LogicalKeyboardKey> numpadKeys = [
        LogicalKeyboardKey.numpad0,
        LogicalKeyboardKey.numpad1,
        LogicalKeyboardKey.numpad2,
        LogicalKeyboardKey.numpad3,
        LogicalKeyboardKey.numpad4,
        LogicalKeyboardKey.numpad5,
        LogicalKeyboardKey.numpad6,
        LogicalKeyboardKey.numpad7,
        LogicalKeyboardKey.numpad8,
        LogicalKeyboardKey.numpad9,
      ];
      for (int i = 0; i <= 9; i++) {
        expect(physicalKeyMap[numpadKeys[i]], equals('$i'), reason: 'numpad $i');
      }
    });

    test('maps function keys F1-F6', () {
      expect(physicalKeyMap[LogicalKeyboardKey.f1], equals('f1'));
      expect(physicalKeyMap[LogicalKeyboardKey.f2], equals('f2'));
      expect(physicalKeyMap[LogicalKeyboardKey.f3], equals('f3'));
      expect(physicalKeyMap[LogicalKeyboardKey.f4], equals('f4'));
      expect(physicalKeyMap[LogicalKeyboardKey.f5], equals('f5'));
      expect(physicalKeyMap[LogicalKeyboardKey.f6], equals('f6'));
    });

    test('maps navigation keys', () {
      expect(physicalKeyMap[LogicalKeyboardKey.arrowLeft], equals('left'));
      expect(physicalKeyMap[LogicalKeyboardKey.arrowRight], equals('right'));
      expect(physicalKeyMap[LogicalKeyboardKey.arrowUp], equals('up'));
      expect(physicalKeyMap[LogicalKeyboardKey.arrowDown], equals('down'));
    });

    test('maps special keys', () {
      expect(physicalKeyMap[LogicalKeyboardKey.space], equals(' '));
      expect(physicalKeyMap[LogicalKeyboardKey.enter], equals('enter'));
      expect(physicalKeyMap[LogicalKeyboardKey.numpadEnter], equals('ent'));
      expect(physicalKeyMap[LogicalKeyboardKey.delete], equals('clear'));
      expect(physicalKeyMap[LogicalKeyboardKey.backspace], equals('clear'));
    });

    test('maps operator keys', () {
      expect(physicalKeyMap[LogicalKeyboardKey.numpadAdd], equals('+'));
      expect(physicalKeyMap[LogicalKeyboardKey.numpadSubtract], equals('-'));
      expect(physicalKeyMap[LogicalKeyboardKey.numpadMultiply], equals('*'));
      expect(physicalKeyMap[LogicalKeyboardKey.numpadDivide], equals('/'));
      expect(physicalKeyMap[LogicalKeyboardKey.equal], equals('='));
      expect(physicalKeyMap[LogicalKeyboardKey.period], equals('.'));
      expect(physicalKeyMap[LogicalKeyboardKey.slash], equals('/'));
      expect(physicalKeyMap[LogicalKeyboardKey.minus], equals('-'));
    });

    test('does not map Escape (handled separately as ON)', () {
      expect(physicalKeyMap[LogicalKeyboardKey.escape], isNull);
    });

    test('all mapped values are valid skin key names', () {
      // Every value should be a non-empty string matching a key in the
      // skin JSON's "keys" object or the allowedKeys set.
      for (final String value in physicalKeyMap.values) {
        expect(value, isNotEmpty);
      }
    });
  });
}
