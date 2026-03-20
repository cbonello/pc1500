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
    group('ME1 → ME0 user RAM routing', () {
      test('ME1 write to \$0000 should be readable from ME0 \$4000', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x10000, 0x42);
        expect(emu.memReadForTest(0x4000), equals(0x42));
      });

      test('ME1 write to \$1000 should be readable from ME0 \$5000', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x11000, 0xAB);
        expect(emu.memReadForTest(0x5000), equals(0xAB));
      });

      test('ME1 read from \$0000 should return ME0 \$4000 data', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x4000, 0x99);
        expect(emu.memReadForTest(0x10000), equals(0x99));
      });

      test('ME1 \$2000+ should NOT route to user RAM', () {
        final Emulator emu = _createEmulator();
        expect(emu.memReadForTest(0x12000), equals(0xFF));
      });

      test('ME1 \$2000+ SHOULD route after CE-155 expansion', () {
        final Emulator emu = _createEmulator();
        emu.addCE155();
        // CE-155 extends ME1 routing to $0000-$2FFF → ME0 $4000-$6FFF.
        emu.memWriteForTest(0x12800, 0xCD);
        expect(emu.memReadForTest(0x6800), equals(0xCD));
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

    group('BASIC program storage via ME1', () {
      test('write via ME1 \$0000 should be readable from ME0 \$4000', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x10000, 0xFF);
        expect(emu.memReadForTest(0x4000), equals(0xFF));
      });

      test('BASIC program storage pattern should work end-to-end', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x10000, 0x00); // line number high
        emu.memWriteForTest(0x10001, 0x0A); // line number low
        emu.memWriteForTest(0x10002, 0x04); // length
        emu.memWriteForTest(0x10003, 0xF0); // PRINT token byte 1
        emu.memWriteForTest(0x10004, 0x97); // PRINT token byte 2
        emu.memWriteForTest(0x10005, 0x37); // '7'
        emu.memWriteForTest(0x10006, 0x0D); // CR
        emu.memWriteForTest(0x10007, 0xFF); // end marker

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
        emu.simulateColdStartDone();
        emu.simulateWarmStartDone();
        expect(emu.memReadForTest(0x4000), equals(0xFF));
      });

      test('warm start should set RAM top for PC-1500A', () {
        final Emulator emu = _createEmulator(HardwareDeviceType.pc1500A);
        emu.simulateColdStartDone();
        emu.simulateWarmStartDone();
        // PC-1500A: 6KB RAM, top = $5800, high byte = $58.
        expect(emu.memReadForTest(0x7899), equals(0x58));
      });

      test('warm start should set RAM top for PC-1500', () {
        final Emulator emu = _createEmulator(HardwareDeviceType.pc1500);
        emu.simulateColdStartDone();
        emu.simulateWarmStartDone();
        // PC-1500: 2KB RAM, top = $4800, high byte = $48.
        expect(emu.memReadForTest(0x7899), equals(0x48));
      });

      test('RAM top should account for CE-151 expansion', () {
        final Emulator emu = _createEmulator(HardwareDeviceType.pc1500A);
        emu.addCE151();
        emu.simulateColdStartDone();
        emu.simulateWarmStartDone();
        // PC-1500A + CE-151 (4KB): top = $5800 + $1000 = $6800, high = $68.
        expect(emu.memReadForTest(0x7899), equals(0x68));
      });

      test('RAM top should account for CE-155 expansion', () {
        final Emulator emu = _createEmulator(HardwareDeviceType.pc1500A);
        emu.addCE155();
        emu.simulateColdStartDone();
        emu.simulateWarmStartDone();
        // PC-1500A + CE-155 (8KB): top = $5800 + $2000 = $7800, high = $78.
        expect(emu.memReadForTest(0x7899), equals(0x78));
      });
    });

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

      test('CE-155 should expand ME1 routing to \$3000', () {
        final Emulator emu = _createEmulator(HardwareDeviceType.pc1500A);
        emu.addCE155();
        // ME1 $2800 → ME0 $6800 (within CE-155 expansion range).
        emu.memWriteForTest(0x12800, 0x77);
        expect(emu.memReadForTest(0x6800), equals(0x77));
        // ME1 $3000+ should still NOT route.
        expect(emu.memReadForTest(0x13000), equals(0xFF));
      });

      test('cannot add two expansion modules', () {
        final Emulator emu = _createEmulator();
        emu.addCE151();
        expect(() => emu.addCE155(), throwsA(isA<EmulatorError>()));
      });

      test('ME1 routing per-instance (not shared global)', () {
        final Emulator emu1 = _createEmulator();
        final Emulator emu2 = _createEmulator();
        emu1.addCE155();
        // emu1 has expanded routing, emu2 does not.
        emu1.memWriteForTest(0x12800, 0x11);
        expect(emu1.memReadForTest(0x6800), equals(0x11));
        // emu2 should NOT route ME1 $2800.
        expect(emu2.memReadForTest(0x12800), equals(0xFF));
      });
    });
  });
}
