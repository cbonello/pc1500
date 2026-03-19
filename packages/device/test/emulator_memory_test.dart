import 'dart:isolate';

import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/emulator.dart';
import 'package:test/test.dart';

/// Creates an [Emulator] instance for testing.
///
/// The emulator requires a [SendPort] but we don't need to receive messages
/// in these tests, so we create a throwaway port.
Emulator _createEmulator() {
  final ReceivePort receivePort = ReceivePort();
  addTearDown(receivePort.close);
  return Emulator(HardwareDeviceType.pc1500A, receivePort.sendPort);
}

void main() {
  group('Emulator memory routing', () {
    group('ME1 → ME0 user RAM routing', () {
      test('ME1 write to \$0000 should be readable from ME0 \$4000', () {
        final Emulator emu = _createEmulator();
        // Write via ME1 $0000 (address 0x10000 in the CPU).
        emu.memWriteForTest(0x10000, 0x42);
        // Read back via ME0 $4000 (where user RAM lives).
        expect(emu.memReadForTest(0x4000), equals(0x42));
      });

      test('ME1 write to \$1000 should be readable from ME0 \$5000', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x11000, 0xAB);
        expect(emu.memReadForTest(0x5000), equals(0xAB));
      });

      test('ME1 read from \$0000 should return ME0 \$4000 data', () {
        final Emulator emu = _createEmulator();
        // Write directly to ME0 $4000.
        emu.memWriteForTest(0x4000, 0x99);
        // Read via ME1 $0000.
        expect(emu.memReadForTest(0x10000), equals(0x99));
      });

      test('ME1 \$2000+ should NOT route to user RAM', () {
        final Emulator emu = _createEmulator();
        // ME1 $2000 is outside the $0000-$1FFF routing range.
        // Should return 0xFF (open bus).
        expect(emu.memReadForTest(0x12000), equals(0xFF));
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
        // ROM value should be unchanged.
        expect(emu.memReadForTest(0xC000), equals(before));
      });

      test('write to \$FFFF should be silently dropped', () {
        final Emulator emu = _createEmulator();
        final int before = emu.memReadForTest(0xFFFF);
        // This should not throw (previously crashed with "Cannot write to ROM").
        emu.memWriteForTest(0xFFFF, 0xE1);
        expect(emu.memReadForTest(0xFFFF), equals(before));
      });
    });

    group('Unmapped gap guard', () {
      test('write to \$5800-\$73FF should be silently dropped', () {
        final Emulator emu = _createEmulator();
        // $6000 is in the unmapped gap between user RAM and display RAM.
        emu.memWriteForTest(0x6000, 0x42);
        // Should return 0 or whatever the default is (no RAM there).
        // The key thing is no exception is thrown.
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

    group('BASIC program storage via ME1', () {
      test('write via ME1 \$0000 should be readable from ME0 \$4000', () {
        final Emulator emu = _createEmulator();
        // The ROM writes BASIC program data via ME1 $0000 (SIN X with
        // ME1 addressing). Our ME1 routing maps to ME0 $4000 (user RAM).
        emu.memWriteForTest(0x10000, 0xFF);
        expect(emu.memReadForTest(0x4000), equals(0xFF));
      });

      test('BASIC program storage pattern should work end-to-end', () {
        final Emulator emu = _createEmulator();
        // Simulate what the ROM does for "10 PRINT 7" via ME1:
        emu.memWriteForTest(0x10000, 0x00); // line number high
        emu.memWriteForTest(0x10001, 0x0A); // line number low
        emu.memWriteForTest(0x10002, 0x04); // length
        emu.memWriteForTest(0x10003, 0xF0); // PRINT token byte 1
        emu.memWriteForTest(0x10004, 0x97); // PRINT token byte 2
        emu.memWriteForTest(0x10005, 0x37); // '7'
        emu.memWriteForTest(0x10006, 0x0D); // CR
        emu.memWriteForTest(0x10007, 0xFF); // end marker

        // Verify readable from ME0 $4000 (direct user RAM access).
        expect(emu.memReadForTest(0x4000), equals(0x00));
        expect(emu.memReadForTest(0x4001), equals(0x0A));
        expect(emu.memReadForTest(0x4002), equals(0x04));
        expect(emu.memReadForTest(0x4003), equals(0xF0));
        expect(emu.memReadForTest(0x4007), equals(0xFF));

        // Also verify readable back via ME1.
        expect(emu.memReadForTest(0x10000), equals(0x00));
        expect(emu.memReadForTest(0x10007), equals(0xFF));
      });
    });

    group('BASIC initialization', () {
      test('warm start should set end-of-program marker at \$4000', () {
        final Emulator emu = _createEmulator();
        // Simulate cold start completing (ROM enters HLT).
        emu.simulateColdStartDone();
        // Simulate warm start completing (second HLT).
        emu.simulateWarmStartDone();
        expect(emu.memReadForTest(0x4000), equals(0xFF));
      });

      test('warm start should set RAM top pointer at \$7899', () {
        final Emulator emu = _createEmulator();
        emu.simulateColdStartDone();
        emu.simulateWarmStartDone();
        // PC-1500A: 6KB RAM, top = $5800, high byte = $58.
        expect(emu.memReadForTest(0x7899), equals(0x58));
      });
    });
  });
}
