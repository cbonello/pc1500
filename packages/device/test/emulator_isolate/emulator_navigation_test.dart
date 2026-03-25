import 'dart:isolate';

import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/emulator.dart';
import 'package:test/test.dart';

/// Creates an [Emulator] with a throwaway port for testing.
Emulator _createEmulator() {
  final ReceivePort receivePort = ReceivePort();
  addTearDown(receivePort.close);

  return Emulator(HardwareDeviceType.pc1500A, receivePort.sendPort);
}

/// Writes a BASIC program line at [addr] in the standard PC-1500 format:
///   2-byte line number (big-endian) + 1-byte length + [data] bytes.
/// Returns the address after the line (next line start).
int _writeLine(Emulator emu, int addr, int lineNum, List<int> data) {
  emu.memWriteForTest(addr, (lineNum >> 8) & 0xFF); // line number high
  emu.memWriteForTest(addr + 1, lineNum & 0xFF); // line number low
  emu.memWriteForTest(addr + 2, data.length); // length
  for (int i = 0; i < data.length; i++) {
    emu.memWriteForTest(addr + 3 + i, data[i]);
  }

  return addr + 3 + data.length;
}

/// Sets up a BASIC program with the given line numbers.
/// Each line gets dummy data [0xF0, 0x97, 0x30+i, 0x0D] (PRINT i).
/// Also writes the end-of-program marker (0xFF) and sets
/// the program base pointer ($7865) and $7880 = $14.
void _setupProgram(Emulator emu, List<int> lineNums) {
  const int base = 0x40C2;
  // Set program base pointer at $7865-$7866.
  emu.memWriteForTest(0x7865, (base >> 8) & 0xFF);
  emu.memWriteForTest(0x7866, base & 0xFF);
  // Set $7880 = $14 (bit 4 set, required for arrow key handler).
  emu.memWriteForTest(0x7880, 0x14);

  int addr = base;
  for (int i = 0; i < lineNums.length; i++) {
    final List<int> data = <int>[0xF0, 0x97, 0x30 + i, 0x0D];
    addr = _writeLine(emu, addr, lineNums[i], data);
  }
  // End-of-program marker.
  emu.memWriteForTest(addr, 0xFF);
}

/// Reads the 16-bit big-endian value at [addr].
int _read16(Emulator emu, int addr) =>
    (emu.memReadForTest(addr) << 8) | emu.memReadForTest(addr + 1);

void main() {
  group('Arrow key navigation', () {
    // ── Program line scanning ───────────────────────────────────────

    group('_programLineAddresses (via prepareNavigateUp)', () {
      test('empty program does not crash', () {
        final Emulator emu = _createEmulator();
        const int base = 0x40C2;
        emu.memWriteForTest(0x7865, (base >> 8) & 0xFF);
        emu.memWriteForTest(0x7866, base & 0xFF);
        emu.memWriteForTest(base, 0xFF); // end marker only

        // Should not throw — just return early.
        emu.prepareNavigateUp();
        // $78A6 unchanged (whatever the default is).
      });
    });

    // ── prepareNavigateUp ───────────────────────────────────────────

    group('prepareNavigateUp', () {
      test('from last line sets \$78A6 to show previous line', () {
        final Emulator emu = _createEmulator();
        _setupProgram(emu, [10, 20, 30]);

        // Simulate: currently showing line 30 (last line).
        // $78A6 points to line 20, so D2B3 advanced past 20 → showed 30.
        const int line20Addr = 0x40C2 + 7; // line 10 is 7 bytes
        emu.memWriteForTest(0x78A6, (line20Addr >> 8) & 0xFF);
        emu.memWriteForTest(0x78A7, line20Addr & 0xFF);

        emu.prepareNavigateUp();

        // Should set $78A6 to line 10's address, so D2B3 advances
        // past line 10 and displays line 20.
        final int result = _read16(emu, 0x78A6);
        expect(result, equals(0x40C2)); // line 10 address
      });

      test('from second line sets \$78A6 to dummy (base-3)', () {
        final Emulator emu = _createEmulator();
        _setupProgram(emu, [10, 20]);

        // Currently showing line 10 (first line).
        // $78A6 = base - 3 (dummy before first line) or some address
        // where D2B3 advanced to show line 10.
        // When $78A6 < first line, displayIndex = 0.
        const int base = 0x40C2;
        emu.memWriteForTest(0x78A6, ((base - 3) >> 8) & 0xFF);
        emu.memWriteForTest(0x78A7, (base - 3) & 0xFF);

        emu.prepareNavigateUp();

        // Already on first line → should stay: $78A6 = base - 3.
        final int result = _read16(emu, 0x78A6);
        expect(result, equals(base - 3));
      });

      test('from middle line navigates back one line', () {
        final Emulator emu = _createEmulator();
        _setupProgram(emu, [10, 20, 30, 40]);

        // Currently showing line 30 (index 2).
        // $78A6 = line 20 address (index 1), D2B3 advanced to show line 30.
        const int line20Addr = 0x40C2 + 7;
        emu.memWriteForTest(0x78A6, (line20Addr >> 8) & 0xFF);
        emu.memWriteForTest(0x78A7, line20Addr & 0xFF);

        emu.prepareNavigateUp();

        // Target = line 20 (index 1). $78A6 should point to line 10
        // (index 0) so D2B3 advances past it and shows line 20.
        final int result = _read16(emu, 0x78A6);
        expect(result, equals(0x40C2)); // line 10 address
      });

      test('updates \$78A8 with target line number', () {
        final Emulator emu = _createEmulator();
        _setupProgram(emu, [10, 20, 30]);

        // Currently showing line 30. $78A6 = line 20 addr.
        const int line20Addr = 0x40C2 + 7;
        emu.memWriteForTest(0x78A6, (line20Addr >> 8) & 0xFF);
        emu.memWriteForTest(0x78A7, line20Addr & 0xFF);

        emu.prepareNavigateUp();

        // $78A8 should contain line number 20 (= 0x0014).
        final int lineNum = _read16(emu, 0x78A8);
        expect(lineNum, equals(20));
      });

      test('at first line stays on first line', () {
        final Emulator emu = _createEmulator();
        _setupProgram(emu, [10, 20, 30]);

        // Currently showing line 10. $78A6 = base - 3.
        const int base = 0x40C2;
        emu.memWriteForTest(0x78A6, ((base - 3) >> 8) & 0xFF);
        emu.memWriteForTest(0x78A7, (base - 3) & 0xFF);

        emu.prepareNavigateUp();

        // Should stay at base - 3 (first line).
        final int result = _read16(emu, 0x78A6);
        expect(result, equals(base - 3));

        // $78A8 should contain line number 10 (= 0x000A).
        final int lineNum = _read16(emu, 0x78A8);
        expect(lineNum, equals(10));
      });
    });

    // ── cycleMode / $7880 init ──────────────────────────────────────

    group('cycleMode sets \$7880', () {
      test('entering PRO mode sets CPU state for BASINPUT2', () {
        final Emulator emu = _createEmulator();
        // Start in RUN mode so cycleMode toggles to PRO.
        emu.memWriteForTest(0x764F, 0x40); // RUN bit set
        emu.memWriteForTest(0x7880, 0x00);

        emu.cycleMode();

        // After toggling RUN → PRO, A = $14, P = BASINPUT2 ($CA7A).
        expect(emu.cpuState.a.value, equals(0x14));
        expect(emu.cpuState.p.value, equals(0xCA7A));
      });
    });

    // ── DEF key toggle ──────────────────────────────────────────────

    group('DEF key toggle', () {
      test('toggleDef sets bit 7 of \$764E', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x764E, 0x00);

        emu.toggleDef();

        expect(emu.memReadForTest(0x764E), equals(0x80));
      });

      test('toggleDef clears bit 7 when already set', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x764E, 0x80);

        emu.toggleDef();

        expect(emu.memReadForTest(0x764E), equals(0x00));
      });

      test('toggleDef preserves other bits', () {
        final Emulator emu = _createEmulator();
        emu.memWriteForTest(0x764E, 0x42); // SHIFT + bank I

        emu.toggleDef();

        expect(emu.memReadForTest(0x764E), equals(0xC2)); // DEF + SHIFT + I
      });
    });
  });
}
