import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockWriteObserver extends Mock implements MemoryObserver {}

void main() {
  group('ChipSelectDecoder', () {
    group('appendRAM()', () {
      test('should raise an exception for invalid arguments', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        expect(
          () => cs.appendRAM(MemoryBank.me0, -1, 100),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendRAM(MemoryBank.me0, 0x20000, 100),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendRAM(MemoryBank.me0, 10, 0),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendRAM(MemoryBank.me0, 10, 64 * 1024),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should detect memory overlaps', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 100);
        expect(
          () => cs.appendRAM(MemoryBank.me0, 10, 100),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });
    });

    group('appendROM()', () {
      test('should raise an exception for invalid arguments', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        expect(
          () => cs.appendROM(MemoryBank.me1, -1, Uint8List(100)),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendROM(MemoryBank.me0, 0x20000, Uint8List(100)),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendROM(MemoryBank.me0, 10, Uint8List(0)),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendROM(MemoryBank.me0, 10, Uint8List(64 * 1024 + 1)),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should detect memory overlaps', () {
        final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 100);
        expect(
          () => cs.appendROM(MemoryBank.me0, 10, data),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });
    });

    test('should append RAMs and ROMs successfully', () {
      final ChipSelectDecoder cs = ChipSelectDecoder();
      final Uint8List data = Uint8List(0xFFFF - 0xC000 + 1);

      cs.appendRAM(MemoryBank.me0, 0x4000, 0x5800 - 0x4000 + 1);
      cs.appendRAM(MemoryBank.me0, 0x7600, 0x7C00 - 0x7600 + 1);
      cs.appendROM(MemoryBank.me0, 0xC000, data);

      cs.appendRAM(MemoryBank.me1, 0x8000, 0x8800 - 0x8000 + 1);
      cs.appendRAM(MemoryBank.me1, 0xB000, 0xB00F - 0xB000 + 1);
      cs.appendRAM(MemoryBank.me1, 0xF000, 0xF00F - 0xF000 + 1);
    });

    test('content of RAMS should be saved/restored successfully', () {
      final ChipSelectDecoder cs1 = ChipSelectDecoder();

      cs1.appendRAM(MemoryBank.me0, 0, 5);
      cs1.writeByteAt(3, 64);
      cs1.appendRAM(MemoryBank.me0, 10, 5);
      cs1.writeByteAt(11, 125);

      final ChipSelectDecoder cs2 = ChipSelectDecoder();
      cs2.appendRAM(MemoryBank.me0, 0, 5);
      cs2.appendRAM(MemoryBank.me0, 10, 5);

      cs2.restoreState(cs1.saveState());
      expect(cs1, equals(cs2));
    });

    group('readByteAt()', () {
      test('should raise an exception for reads to invalid addresses', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 1024);

        // Invalid addresses.
        expect(
          () => cs.readByteAt(-1),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
        expect(
          () => cs.readByteAt(256 * 1024),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );

        // Unmapped address.
        expect(
          () => cs.readByteAt(2048),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should read successfully', () {
        final Uint8List data = Uint8List.fromList(<int>[10, 20, 30, 40]);
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendROM(MemoryBank.me0, 10, data);
        expect(cs.readByteAt(11), equals(20));
      });
    });

    group('writeByteAt()', () {
      test('should raise an exception for writes to invalid addresses', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 1024);

        // Invalid addresses.
        expect(
          () => cs.writeByteAt(-1, 9),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
        expect(
          () => cs.writeByteAt(256 * 1024, 6),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );

        // Unmapped address.
        expect(
          () => cs.writeByteAt(2048, 56),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should write successfully', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 1024);
        cs.writeByteAt(256, 64);
        expect(cs.readByteAt(256), equals(64));
      });
    });
  });
}
