import 'package:annotations/src/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('AddressSpace', () {
    test('should detect malformed tags', () {
      expect(
        () => AddressSpace.fromTag(null),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      expect(
        () => AddressSpace.fromTag(''),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // Valid tag length: 4, 5, 9, and 11.
      expect(
        () => AddressSpace.fromTag('1'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // Hexadecimal digits only.
      expect(
        () => AddressSpace.fromTag('1xyz'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // ME1 address: '#' followed by 4 hexadecimal digits.
      expect(
        () => AddressSpace.fromTag('99999'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // ME0 address-space: two 4 hexadecimal digits separated by a '-'.
      expect(
        () => AddressSpace.fromTag('123456789'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // ME1 address-space: two ME1 addresses separated by a '-'.
      expect(
        () => AddressSpace.fromTag('%1234-%6789'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
      // end address must be greater than or equal to start address.
      expect(
        () => AddressSpace.fromTag('9999-1111'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    });

    test('should create an instance of AddressSpace successfully', () {
      AddressSpace addressSpace;

      expect(
        addressSpace = AddressSpace.fromTag('1234'),
        equals(const TypeMatcher<AddressSpace>()),
      );
      expect(addressSpace.tag, equals('1234'));
      expect(addressSpace.start, equals(0x1234));
      expect(addressSpace.end, equals(0x1234));

      expect(
        addressSpace = AddressSpace.fromTag('1234-5678'),
        equals(const TypeMatcher<AddressSpace>()),
      );
      expect(addressSpace.tag, equals('1234-5678'));
      expect(addressSpace.start, equals(0x1234));
      expect(addressSpace.end, equals(0x5678));

      expect(
        addressSpace = AddressSpace.fromTag('#1234'),
        equals(const TypeMatcher<AddressSpace>()),
      );
      expect(addressSpace.tag, equals('#1234'));
      expect(addressSpace.start, equals(0x11234));
      expect(addressSpace.end, equals(0x11234));

      expect(
        addressSpace = AddressSpace.fromTag('#1234-#5678'),
        equals(const TypeMatcher<AddressSpace>()),
      );
      expect(addressSpace.tag, equals('#1234-#5678'));
      expect(addressSpace.start, equals(0x11234));
      expect(addressSpace.end, equals(0x15678));
    });

    group('length getter', () {
      test('should return the address-space size', () {
        expect(
          AddressSpace.fromTag('1234').length,
          equals(1),
        );
        expect(
          AddressSpace.fromTag('0004-0008').length,
          equals(8 - 4 + 1),
        );
      });
    });

    group('memoryBank getter', () {
      test(
        'should return the memory bank corresponding to the address-space',
        () {
          expect(
            AddressSpace.fromTag('1234').memoryBank,
            equals(0),
          );
          expect(
            AddressSpace.fromTag('#0012-#1234').memoryBank,
            equals(1),
          );
        },
      );
    });

    group('containsAddress()', () {
      test(
        'should detect if an address is included in the address-space',
        () {
          expect(
            AddressSpace.fromTag('1234').containsAddress(0x1234),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('1234').containsAddress(0x12),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('1234-5678').containsAddress(0x3456),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('1234-5678').containsAddress(0xFFFF),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('#1234').containsAddress(0x11234),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('#1234').containsAddress(0x4),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('#1234-#5678').containsAddress(0x13456),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('#1234-#5678').containsAddress(0x3456),
            isFalse,
          );
        },
      );
    });

    group('containsAddressSpace()', () {
      test(
        'should detect if an address-space is included in another address-space',
        () {
          final AddressSpace me0AddressSpace = AddressSpace.fromTag('1234');
          final AddressSpace me1AddressSpace = AddressSpace.fromTag('#1234');

          expect(
            AddressSpace.fromTag('1234').containsAddressSpace(me0AddressSpace),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('1221').containsAddressSpace(me0AddressSpace),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('1234-5678')
                .containsAddressSpace(me0AddressSpace),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('1235-5678')
                .containsAddressSpace(me0AddressSpace),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('#1234').containsAddressSpace(me1AddressSpace),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('#1230').containsAddressSpace(me1AddressSpace),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('#1234-#5678')
                .containsAddressSpace(me1AddressSpace),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('#4321-#5678')
                .containsAddressSpace(me1AddressSpace),
            isFalse,
          );
        },
      );
    });

    group('intersectWith()', () {
      test(
        'should detect if an address-space intersect with another address-space',
        () {
          final AddressSpace me0AddressSpace = AddressSpace.fromTag('1234');
          final AddressSpace me1AddressSpace = AddressSpace.fromTag('#1234');

          expect(
            AddressSpace.fromTag('1234').intersectWith(me0AddressSpace),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('1221').intersectWith(me0AddressSpace),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('1234-5678').intersectWith(
              me0AddressSpace,
            ),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('1235-5678').intersectWith(
              me0AddressSpace,
            ),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('#1234').intersectWith(me1AddressSpace),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('#1230').intersectWith(me1AddressSpace),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('#1234-#5678').intersectWith(
              me1AddressSpace,
            ),
            isTrue,
          );
          expect(
            AddressSpace.fromTag('#4321-#5678').intersectWith(
              me1AddressSpace,
            ),
            isFalse,
          );
          expect(
            AddressSpace.fromTag('#0010-#0020').intersectWith(
              AddressSpace.fromTag('#0000-#00FF'),
            ),
            isTrue,
          );
        },
      );
    });

    test('iterator should return the expected values', () {
      int count;
      Iterator<int> iterator = AddressSpace.fromTag('1234').iterator;

      count = 0;
      while (iterator.moveNext()) {
        expect(iterator.current, equals(0x1234));
        count++;
      }
      expect(count, equals(1));

      iterator = AddressSpace.fromTag('0010-0020').iterator;

      count = 0;
      while (iterator.moveNext()) {
        expect(iterator.current, equals(0x0010 + count));
        count++;
      }
      expect(count, equals(0x0020 - 0x0010 + 1));
    });

    group('toString()', () {
      test('should display the expected data', () {
        expect(
          AddressSpace.fromTag('1234').toString(),
          equals('[1234]'),
        );
        expect(
          AddressSpace.fromTag('#1234-#5678').toString(),
          equals('[#1234-#5678]'),
        );
      });
    });
  });
}
