import 'dart:typed_data';

import 'package:lcd/lcd.dart';
import 'package:test/test.dart';

final Uint8ClampedList me0 = Uint8ClampedList(64 * 1024);

void memLoad(int address, List<int> data) =>
    me0.setRange(address, address + data.length, data);

Uint8ClampedList memRead(int address, int length) =>
    me0.sublist(address, address + length);

void main() {
  group('Lcd', () {
    test('should raise an exception for invalid arguments', () {
      expect(
        () => Lcd(memRead: null),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('should be intialized successfully', () {
      expect(Lcd(memRead: memRead), isA<Lcd>());
    });
  });
}
