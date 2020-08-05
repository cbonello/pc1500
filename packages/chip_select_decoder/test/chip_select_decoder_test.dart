import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockWriteObserver extends Mock implements WriteObserver {}

void main() {
  group('ChipSelect', () {
    group('appendRAM() / appendROM()', () {
      test('should raise an exception for invalid arguments', () {
        final ChipSelect cs = ChipSelect();

        expect(
          () => cs.appendRAM(MemoryBank.me0, -1, 100),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendRAM(MemoryBank.me0, 10, 0),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendRAM(MemoryBank.me0, 10, 64 * 1024),
          throwsA(const TypeMatcher<ChipSelectError>()),
        );
      });

      test('should detect memory overlaps', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
        final ChipSelect cs = ChipSelect();

        cs.appendRAM(MemoryBank.me0, 0, 100);
        expect(
          () => cs.appendROM(MemoryBank.me0, 10, data),
          throwsA(const TypeMatcher<ChipSelectError>()),
        );
      });

      test('should append RAMs and ROMs successfully', () {
        final ChipSelect cs = ChipSelect();
        final Uint8List data = Uint8List(0xFFFF - 0xC000 + 1);

        cs.appendRAM(MemoryBank.me0, 0x4000, 0x5800 - 0x4000 + 1);
        cs.appendRAM(MemoryBank.me0, 0x7600, 0x7C00 - 0x7600 + 1);
        cs.appendROM(MemoryBank.me0, 0xC000, data);

        cs.appendRAM(MemoryBank.me1, 0x8000, 0x8800 - 0x8000 + 1);
        cs.appendRAM(MemoryBank.me1, 0xB000, 0xB00F - 0xB000 + 1);
        cs.appendRAM(MemoryBank.me1, 0xF000, 0xF00F - 0xF000 + 1);
      });
    });

    test('content of RAMS should be saved/restored successfully', () {
      final ChipSelect cs1 = ChipSelect();

      cs1.appendRAM(MemoryBank.me0, 0, 5);
      cs1.writeByteAt(3, 64);
      cs1.appendRAM(MemoryBank.me0, 10, 5);
      cs1.writeByteAt(11, 125);

      final ChipSelect cs2 = ChipSelect();
      cs2.appendRAM(MemoryBank.me0, 0, 5);
      cs2.appendRAM(MemoryBank.me0, 10, 5);

      cs2.restoreState(cs1.saveState());
      expect(cs1, equals(cs2));
    });

    group('readByteAt()', () {
      test('should raise an exception for reads to invalid addresses', () {
        final ChipSelect cs = ChipSelect();

        cs.appendRAM(MemoryBank.me0, 0, 1024);

        // Invalid addresses.
        expect(
          () => cs.readByteAt(-1),
          throwsA(const TypeMatcher<ChipSelectError>()),
        );
        expect(
          () => cs.readByteAt(256 * 1024),
          throwsA(const TypeMatcher<ChipSelectError>()),
        );

        // Unmapped address.
        expect(
          () => cs.readByteAt(2048),
          throwsA(const TypeMatcher<ChipSelectError>()),
        );
      });

      test('should read successfully', () {
        final Uint8List data = Uint8List.fromList(<int>[10, 20, 30, 40]);
        final ChipSelect cs = ChipSelect();

        cs.appendROM(MemoryBank.me0, 10, data);
        expect(cs.readByteAt(11), equals(20));
      });
    });

    group('writeByteAt()', () {
      test('should raise an exception for writes to invalid addresses', () {
        final ChipSelect cs = ChipSelect();

        cs.appendRAM(MemoryBank.me0, 0, 1024);

        // Invalid addresses.
        expect(
          () => cs.writeByteAt(-1, 9),
          throwsA(const TypeMatcher<ChipSelectError>()),
        );
        expect(
          () => cs.writeByteAt(256 * 1024, 6),
          throwsA(const TypeMatcher<ChipSelectError>()),
        );

        // Unmapped address.
        expect(
          () => cs.writeByteAt(2048, 56),
          throwsA(const TypeMatcher<ChipSelectError>()),
        );
      });

      test('should write successfully', () {
        final ChipSelect cs = ChipSelect();

        cs.appendRAM(MemoryBank.me0, 0, 1024);
        cs.writeByteAt(256, 64);
        expect(cs.readByteAt(256), equals(64));
      });

      test('should call write observers', () {
        final ChipSelect cs = ChipSelect();
        final MockWriteObserver observer1 = MockWriteObserver();
        final MockWriteObserver observer2 = MockWriteObserver();

        cs.appendRAM(MemoryBank.me0, 0, 1024, observer1);
        cs.appendRAM(MemoryBank.me0, 2048, 1024, observer2);

        cs.writeByteAt(256, 64);
        verify(observer1.checkWrite(any, any)).called(1);
        verifyNever(observer2.checkWrite(any, any));

        cs.writeByteAt(2059, 125);
        verifyNever(observer1.checkWrite(any, any));
        verify(observer2.checkWrite(any, any)).called(1);
      });
    });
  });
}
