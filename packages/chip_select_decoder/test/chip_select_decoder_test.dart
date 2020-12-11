import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:crypto/crypto.dart';
import 'package:mockito/mockito.dart';
import 'package:roms/roms.dart';
import 'package:test/test.dart';

class MockRom extends Mock implements RomBase {}

MockRom createMockRom(int length) {
  assert(length <= 16 * 1024);

  final Uint8List bytes = Uint8List(length);
  for (int i = 0; i < length; i++) {
    bytes[i] = i;
  }

  final MockRom rom = MockRom();
  when(rom.bytes).thenReturn(bytes);
  when(rom.hash).thenReturn(sha1.convert(bytes));

  return rom;
}

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
        expect(cs.memoryBanks[MemoryBank.me0].length, equals(1));

        expect(
          () => cs.appendRAM(MemoryBank.me0, 10, 100),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });
    });

    group('appendROM()', () {
      test('should raise an exception for invalid arguments', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();
        final MockRom rom = createMockRom(1000);
        final MockRom rom0 = createMockRom(0);

        expect(
          () => cs.appendROM(MemoryBank.me1, -1, rom),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendROM(MemoryBank.me0, 0x20000, rom),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendROM(MemoryBank.me0, 10, rom0),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendROM(MemoryBank.me0, 0x10000 - 500, rom),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should detect memory overlaps', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();
        final MockRom rom = createMockRom(10);

        cs.appendRAM(MemoryBank.me0, 0, 100);
        expect(
          () => cs.appendROM(MemoryBank.me0, 10, rom),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });
    });

    group('appendROMPlaceholder()', () {
      test('should raise an exception for invalid arguments', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        expect(
          () => cs.appendROMPlaceholder(MemoryBank.me0, -1, 100, 0x1A),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendROMPlaceholder(MemoryBank.me0, 0x20000, 100, 0x1B),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendROMPlaceholder(MemoryBank.me0, 10, 0, 0x1C),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
        expect(
          () => cs.appendROMPlaceholder(MemoryBank.me0, 10, 64 * 1024, 0x1D),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should detect memory overlaps', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendROMPlaceholder(MemoryBank.me0, 0, 100, 0x00);
        expect(cs.memoryBanks[MemoryBank.me0].length, equals(1));

        expect(
          () => cs.appendROMPlaceholder(MemoryBank.me0, 10, 100, 0xFF),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });
    });

    test('should append RAMs and ROMs successfully', () {
      final ChipSelectDecoder cs = ChipSelectDecoder();
      final MockRom rom = createMockRom(16 * 1024);

      cs.appendRAM(MemoryBank.me0, 0x4000, 0x5800 - 0x4000 + 1);
      cs.appendRAM(MemoryBank.me0, 0x7600, 0x7C00 - 0x7600 + 1);
      cs.appendROM(MemoryBank.me0, 0xC000, rom);
      expect(cs.memoryBanks[MemoryBank.me0].length, equals(3));

      cs.appendROMPlaceholder(MemoryBank.me1, 0x8000, 0x10, 0xFF);
      cs.appendROMPlaceholder(MemoryBank.me1, 0xB000, 0x10, 0xFF);
      cs.appendRAM(MemoryBank.me1, 0xF000, 0xF00F - 0xF000 + 1);
      expect(cs.memoryBanks[MemoryBank.me1].length, equals(3));
    });

    test('content of RAMs should be saved/restored successfully', () {
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

    group('readAt()', () {
      test('should raise an exception for reads from invalid addresses', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 1024);

        // Invalid addresses.
        expect(
          () => cs.readAt(-1, 1),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );

        // Unmapped address.
        expect(
          () => cs.readAt(2048, 1),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should raise an exception for reads for an invalid length', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 128);

        // Invalid length.
        expect(
          () => cs.readAt(0, -1),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
        expect(
          () => cs.readAt(0, 0),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );

        // Read past memory size.
        expect(
          () => cs.readAt(0, 129),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should read successfully', () {
        final MockRom rom = createMockRom(128);
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 128);
        for (int i = 0; i < 128; i++) {
          cs.writeByteAt(i, i);
        }
        cs.appendROM(MemoryBank.me0, 1000, rom);
        cs.appendROMPlaceholder(MemoryBank.me0, 0x8000, 0x10, 0xFF);
        expect(cs.readAt(64, 3).toList(), equals(<int>[64, 65, 66]));
        expect(cs.readAt(1012, 2).toList(), equals(<int>[12, 13]));
        expect(cs.readAt(0x8002, 3).toList(), equals(<int>[0xFF, 0xFF, 0xFF]));
      });
    });

    group('readByteAt()', () {
      test('should raise an exception for reads from invalid addresses', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 1024);

        // Invalid addresses.
        expect(
          () => cs.readByteAt(-1),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );

        // Unmapped address.
        expect(
          () => cs.readByteAt(2048),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should read successfully', () {
        final MockRom rom = createMockRom(128);
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 512);
        cs.appendROM(MemoryBank.me0, 1000, rom);
        cs.appendROMPlaceholder(MemoryBank.me0, 0x8000, 0x10, 0xFF);
        expect(cs.readByteAt(256), equals(0));
        expect(cs.readByteAt(1012), equals(12));
        expect(cs.readByteAt(0x8002), equals(0xFF));
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

        // Unmapped address.
        expect(
          () => cs.writeByteAt(2048, 56),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should raise an exception for writes to ROMs', () {
        final MockRom rom = createMockRom(128);
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendROM(MemoryBank.me0, 0, rom);
        expect(
          () => cs.writeByteAt(10, 9),
          throwsA(const TypeMatcher<ChipSelectDecoderError>()),
        );
      });

      test('should write successfully', () {
        final ChipSelectDecoder cs = ChipSelectDecoder();

        cs.appendRAM(MemoryBank.me0, 0, 512);
        cs.appendROMPlaceholder(MemoryBank.me0, 0x8000, 0x10, 0xFF);
        cs.writeByteAt(256, 89);
        expect(cs.readByteAt(256), equals(89));
        cs.writeByteAt(0x8002, 1);
        expect(cs.readByteAt(0x8002), equals(0xFF));
      });
    });
  });
}
