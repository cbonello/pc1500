import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/repositories/systems/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sharp PC-1500A Skin', () {
    test('Parses pc1500a.json successfully', () async {
      final File file = File('assets/systems/pc1500a.json');
      final dynamic json = jsonDecode(await file.readAsString());
      final SkinModel skin = SkinModel.fromJson(json as Map<String, dynamic>);
      expect(skin.keyColors.length, greaterThan(0));
      checkSkin(skin);
    });
  });

  group('Radio Shack TRS-80 PC-2 Skin', () {
    test('Parses pc2.json successfully', () async {
      final File file = File('assets/systems/pc2.json');
      final dynamic json = jsonDecode(await file.readAsString());
      final SkinModel skin = SkinModel.fromJson(json as Map<String, dynamic>);

      await checkSkin(skin);
    });
  });
}

void checkColorModel(ColorModel color) {
  checkColor(color.background);
}

void checkColor(int color) {
  expect(color, greaterThanOrEqualTo(0));
  expect(color, lessThanOrEqualTo(0xFFFFFFFF));
}

Future<void> checkSkin(SkinModel skin) async {
  expect(skin.image, isNotNull);
  // Asset exists?
  await expectLater(rootBundle.load(skin.image), completion(isNotNull));

  expect(skin.lcd, isNotNull);
  expect(skin.lcd.colors.background, isNotNull);
  checkColor(skin.lcd.colors.background);
  expect(skin.lcd.colors.pixelOn, isNotNull);
  checkColor(skin.lcd.colors.pixelOn);
  expect(skin.lcd.colors.pixelOff, isNotNull);
  checkColor(skin.lcd.colors.pixelOff);
  expect(skin.lcd.colors.symbolOn, isNotNull);
  checkColor(skin.lcd.colors.symbolOn);
  expect(skin.lcd.colors.symbolOff, isNotNull);
  checkColor(skin.lcd.colors.symbolOff);
  expect(skin.lcd.top, greaterThan(0));
  expect(skin.lcd.left, isNotNull);
  expect(skin.lcd.left, greaterThan(0));
  expect(skin.lcd.height, isNotNull);
  expect(skin.lcd.height, greaterThan(0));
  expect(skin.lcd.width, isNotNull);
  expect(skin.lcd.width, greaterThan(0));

  expect(skin.keyColors.length, greaterThan(0));
  skin.keyColors.values.forEach(checkColorModel);

  expect(skin.keys, isNotNull);
  expect(skin.keys.length, equals(allowedKeys.length));
  for (final String key in skin.keys.keys) {
    expect(allowedKeys.contains(key), isTrue);
    checkKey(skin.keyColors.keys, skin.keys[key]);
  }
}

void checkKey(Iterable<String> colors, KeyModel key) {
  expect(key.label, isNotNull);
  key.label.when<void>(
    text: (String value) {
      expect(key.label.value, isNotNull);
      expect(key.label.value.isNotEmpty, isTrue);
    },
    icon: (String value) {
      expect(key.label.value, isNotNull);
      expect(key.label.value.isNotEmpty, isTrue);
      expect(
        <String>['left', 'up', 'right', 'down', 'up-down'].contains(
          key.label.value,
        ),
        isTrue,
      );
    },
  );
  expect(colors.contains(key.color), isTrue);
  expect(key.fontSize, isNotNull);
  expect(key.fontSize, greaterThan(10));
  expect(key.fontSize, lessThan(48));
  expect(key.top, isNotNull);
  expect(key.top, greaterThan(0));
  expect(key.left, isNotNull);
  expect(key.left, greaterThan(0));
  expect(key.height, isNotNull);
  expect(key.height, greaterThan(0));
  expect(key.width, isNotNull);
  expect(key.width, greaterThan(0));
}

const Set<String> allowedKeys = <String>{
  'off',
  'on',
  'def',
  'f1',
  'f2',
  'f3',
  'f4',
  'f5',
  'f6',
  'shift',
  'q',
  'w',
  'e',
  'r',
  't',
  'y',
  'u',
  'i',
  'o',
  'p',
  '7',
  '8',
  '9',
  '/',
  'clear',
  'a',
  's',
  'd',
  'f',
  'g',
  'h',
  'j',
  'k',
  'l',
  '=',
  '4',
  '5',
  '6',
  '*',
  'mode',
  'z',
  'x',
  'c',
  'v',
  'b',
  'n',
  'm',
  '(',
  ')',
  'up',
  '1',
  '2',
  '3',
  '-',
  'small',
  'up-down',
  'recall',
  ' ',
  'enter',
  'left',
  'right',
  'down',
  '0',
  '.',
  'ent',
  '+',
};
