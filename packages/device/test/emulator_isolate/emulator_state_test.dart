import 'dart:isolate';

import 'package:device/src/device.dart';
import 'package:device/src/emulator_isolate/emulator.dart';
import 'package:test/test.dart';

/// Creates an [Emulator] with a throwaway port for testing.
Emulator _createEmulator([
  HardwareDeviceType type = HardwareDeviceType.pc1500A,
]) {
  final ReceivePort receivePort = ReceivePort();
  addTearDown(receivePort.close);
  return Emulator(type, receivePort.sendPort);
}

/// Reads the 16-bit big-endian value at [addr].
int _read16(Emulator emu, int addr) =>
    (emu.memReadForTest(addr) << 8) | emu.memReadForTest(addr + 1);

void main() {
  group('Emulator saveState / restoreState', () {
    test('round-trip preserves CPU registers', () {
      final Emulator emu = _createEmulator();
      // Set some non-default CPU state.
      emu.step(); // Execute at least one instruction so CPU is past reset.

      final Map<String, dynamic> state = emu.saveState();

      final Emulator restored = _createEmulator();
      restored.restoreState(state);

      // Verify CPU registers match.
      expect(restored.pc, equals(emu.pc));
    });

    test('round-trip preserves RAM content', () {
      final Emulator emu = _createEmulator();
      // Write a small BASIC program.
      const int base = 0x40C2;
      emu.memWriteForTest(base, 0x00); // line number high
      emu.memWriteForTest(base + 1, 0x0A); // line number low (10)
      emu.memWriteForTest(base + 2, 0x04); // length
      emu.memWriteForTest(base + 3, 0xF0); // PRINT token
      emu.memWriteForTest(base + 4, 0x97);
      emu.memWriteForTest(base + 5, 0x31); // "1"
      emu.memWriteForTest(base + 6, 0x0D); // CR
      emu.memWriteForTest(base + 7, 0xFF); // end marker

      final Map<String, dynamic> state = emu.saveState();

      final Emulator restored = _createEmulator();
      restored.restoreState(state);

      // Verify program bytes.
      for (int i = 0; i <= 7; i++) {
        expect(
          restored.memReadForTest(base + i),
          equals(emu.memReadForTest(base + i)),
          reason: 'byte at \$${(base + i).toRadixString(16)}',
        );
      }
    });

    test('round-trip preserves system pointers', () {
      final Emulator emu = _createEmulator();
      // Set program base pointer.
      emu.memWriteForTest(0x7865, 0x40);
      emu.memWriteForTest(0x7866, 0xC2);
      // Set end-of-program pointer.
      emu.memWriteForTest(0x7867, 0x40);
      emu.memWriteForTest(0x7868, 0xD0);

      final Map<String, dynamic> state = emu.saveState();

      final Emulator restored = _createEmulator();
      restored.restoreState(state);

      expect(_read16(restored, 0x7865), equals(0x40C2));
      expect(_read16(restored, 0x7867), equals(0x40D0));
    });

    test('round-trip preserves boot flags', () {
      final Emulator emu = _createEmulator();
      // Trigger a power-on to set _hasBooted.
      emu.powerOn();

      final Map<String, dynamic> state = emu.saveState();
      expect(state['hasBooted'], isTrue);

      final Emulator restored = _createEmulator();
      restored.restoreState(state);
      // Verify by saving again — flags should match.
      final Map<String, dynamic> restoredState = restored.saveState();
      expect(restoredState['hasBooted'], equals(state['hasBooted']));
      expect(
        restoredState['coldStartDone'],
        equals(state['coldStartDone']),
      );
    });

    test('saveState includes version and device type', () {
      final Emulator emu = _createEmulator();
      final Map<String, dynamic> state = emu.saveState();

      expect(state['version'], equals(1));
      expect(state['deviceType'], equals('pc1500A'));
      expect(state.containsKey('cpu'), isTrue);
      expect(state.containsKey('memory'), isTrue);
      expect(state.containsKey('pc1500IO'), isTrue);
      expect(state.containsKey('ce153IO'), isTrue);
    });

    test('restoreState throws on version mismatch', () {
      final Emulator emu = _createEmulator();
      final Map<String, dynamic> state = emu.saveState();
      state['version'] = 99;

      final Emulator restored = _createEmulator();
      expect(
        () => restored.restoreState(state),
        throwsA(isA<StateError>()),
      );
    });

    test('restoreState throws on device type mismatch', () {
      final Emulator emu = _createEmulator();
      final Map<String, dynamic> state = emu.saveState();

      final Emulator restored = _createEmulator(HardwareDeviceType.pc1500);
      expect(
        () => restored.restoreState(state),
        throwsA(isA<StateError>()),
      );
    });

    test('restoreState throws on missing keys', () {
      final Emulator restored = _createEmulator();
      expect(
        () => restored.restoreState(<String, dynamic>{
          'version': 1,
          'deviceType': 'pc1500A',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
