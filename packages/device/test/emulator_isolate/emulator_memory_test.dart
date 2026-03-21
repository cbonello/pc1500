// ignore_for_file: avoid_redundant_argument_values

import 'dart:isolate';

import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/emulator.dart';
import 'package:test/test.dart';

/// Creates an [Emulator] instance for testing.
///
/// The emulator requires a [SendPort] but we don't need to receive messages
/// in these tests, so we create a throwaway port.
Emulator _createEmulator([
  HardwareDeviceType type = HardwareDeviceType.pc1500A,
]) {
  final ReceivePort receivePort = ReceivePort();
  addTearDown(receivePort.close);

  return Emulator(type, receivePort.sendPort);
}

void main() {
  group('Emulator memory routing', () {
    // ME1 has no user RAM — only I/O ports and display chips.
    // Per the TRM Memory Map I, ME1 $0000-$7FFF is "NOT USED".
    group('ME1 user area is unmapped', () {
      test('ME1 read from \$0000 should return \$FF (open bus)', () {
        final Emulator emu = _createEmulator();
        expect(emu.memReadForTest(0x10000), equals(0xFF));
      });

      test('ME1 write to \$0000 should NOT affect ME0 \$4000', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x10000, 0x42);
        expect(emu.memReadForTest(0x4000), equals(0x00));
      });
    });

    group('ME1 → ME0 display/system RAM routing', () {
      test('ME1 write to \$7600 should be readable from ME0 \$7600', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x17600, 0x55);
        expect(emu.memReadForTest(0x7600), equals(0x55));
      });

      test('ME1 write to \$7B00 should be readable from ME0 \$7B00', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x17B00, 0xAA);
        expect(emu.memReadForTest(0x7B00), equals(0xAA));
      });
    });

    group('Display chip mirror', () {
      test('write to \$7400 should mirror to \$7600', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x7400, 0x12);
        expect(emu.memReadForTest(0x7600), equals(0x12));
      });

      test('write to \$7600 should mirror to \$7400', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x7600, 0x34);
        expect(emu.memReadForTest(0x7400), equals(0x34));
      });

      test('write to \$7500 should mirror to \$7700', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x7500, 0x56);
        expect(emu.memReadForTest(0x7700), equals(0x56));
      });

      test('write to \$7700 should mirror to \$7500', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x7700, 0x78);
        expect(emu.memReadForTest(0x7500), equals(0x78));
      });
    });

    group('ROM write guard', () {
      test('write to ROM (\$C000+) should be silently dropped', () {
        final Emulator emu = _createEmulator();
        final int before = emu.memReadForTest(0xC000);
        emu.memWriteForTest(0xC000, 0x00);
        expect(emu.memReadForTest(0xC000), equals(before));
      });

      test('write to \$FFFF should be silently dropped', () {
        final Emulator emu = _createEmulator();
        final int before = emu.memReadForTest(0xFFFF);
        emu.memWriteForTest(0xFFFF, 0xE1);
        expect(emu.memReadForTest(0xFFFF), equals(before));
      });
    });

    group('Unmapped gap guard', () {
      test('write to \$5800-\$73FF should be silently dropped', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x6000, 0x42);
        // No exception is thrown.
      });
    });

    group('User RAM direct access', () {
      test('write to ME0 \$4000 should persist', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x4000, 0xDE);
        expect(emu.memReadForTest(0x4000), equals(0xDE));
      });

      test('write to ME0 \$57FF should persist (end of 6KB)', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x57FF, 0xAD);
        expect(emu.memReadForTest(0x57FF), equals(0xAD));
      });
    });

    // BASIC programs are stored in ME0 user RAM directly — not via ME1.
    group('BASIC program storage in ME0', () {
      test('program pattern at ME0 \$4000 should persist', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x4000, 0x00); // line number high
        emu.memWriteForTest(0x4001, 0x0A); // line number low
        emu.memWriteForTest(0x4002, 0x04); // length
        emu.memWriteForTest(0x4003, 0xF0); // PRINT token byte 1
        emu.memWriteForTest(0x4007, 0xFF); // end marker

        expect(emu.memReadForTest(0x4000), equals(0x00));
        expect(emu.memReadForTest(0x4001), equals(0x0A));
        expect(emu.memReadForTest(0x4003), equals(0xF0));
        expect(emu.memReadForTest(0x4007), equals(0xFF));
      });
    });

    // RAM top and BASIC program area initialization are handled by the
    // ROM's cold start memory probe — no emulator-side patching needed.
    // The ROM writes test patterns to each 256-byte block, detects which
    // addresses have RAM, and sets up system variables accordingly.

    group('Expansion modules', () {
      test('CE-151 should add RAM at \$5800 for PC-1500A', () {
        final Emulator emu = _createEmulator(HardwareDeviceType.pc1500A);
        emu.addCE151();
        emu.memWriteForTest(0x5800, 0xBE);
        expect(emu.memReadForTest(0x5800), equals(0xBE));
      });

      test('CE-155 should add RAM at \$5800 for PC-1500A', () {
        final Emulator emu = _createEmulator(HardwareDeviceType.pc1500A);
        emu.addCE155();
        emu.memWriteForTest(0x6F00, 0xEF);
        expect(emu.memReadForTest(0x6F00), equals(0xEF));
      });

      test('cannot add two expansion modules', () {
        final Emulator emu = _createEmulator();
        emu.addCE151();
        expect(() => emu.addCE155(), throwsA(isA<EmulatorError>()));
      });
    });
  });
}
