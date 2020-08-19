import 'package:roms/src/entities/address_range.dart';
import 'package:test/test.dart';

void main() {
  group('AddressRange', () {
    test('should detect invalid arguments', () {
      expect(
        () => AddressRange.fromTag(null),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      expect(
        () => AddressRange.fromTag(''),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      expect(
        () => AddressRange.fromTag('0'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      expect(
        () => AddressRange.fromTag('wxyz'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      expect(
        () => AddressRange.fromTag('123456789'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      expect(
        () => AddressRange.fromTag('0020-001F'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('should be initialized properly', () {
      AddressRange range = AddressRange.fromTag('1234');
      expect(range.start, equals(0x1234));
      expect(range.end, equals(0x1234));

      range = AddressRange.fromTag('1234-5678');
      expect(range.start, equals(0x1234));
      expect(range.end, equals(0x5678));
    });

    group('contains()', () {
      test('should return false if test fails', () {
        final AddressRange range = AddressRange.fromTag('1234');
        expect(range.contains(0), isFalse);
      });

      test('should return true if test succeed', () {
        final AddressRange range = AddressRange.fromTag('1234');
        expect(range.contains(0x1234), isTrue);
      });
    });

    test('toString() should return the expected value', () {
      final AddressRange range = AddressRange.fromTag('1234');
      expect(range.toString(), equals('AddressRange(4660, 4660)'));
    });
  });
}
