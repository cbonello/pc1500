import 'package:lh5811/lh5811.dart';
import 'package:test/test.dart';

void main() {
  late LH5811 io;
  late int interruptCount;

  setUp(() {
    interruptCount = 0;
    io = LH5811(onInterrupt: () => interruptCount++);
  });

  group('LH5811', () {
    test('should create an instance successfully', () {
      expect(io, isA<LH5811>());
    });

    test('reset should clear all registers', () {
      io.write(0x09, 0xFF); // G register.
      io.write(0x0A, 0x0F); // MSK register.
      io.write(0x0C, 0xFF); // DDA register.
      io.write(0x0E, 0xAA); // OPA register.
      io.reset();
      expect(io.read(0x09), equals(0));
      expect(io.read(0x0A), equals(0));
      expect(io.read(0x0C), equals(0));
      expect(io.read(0x0E), equals(0));
    });

    group('G register (0x09)', () {
      test('should read/write correctly', () {
        io.write(0x09, 0xAB);
        expect(io.read(0x09), equals(0xAB));
      });
    });

    group('F register (0x07)', () {
      test('should mask bit 7', () {
        io.write(0x07, 0xFF);
        expect(io.read(0x07), equals(0x7F));
      });
    });

    group('OPC register (0x08)', () {
      test('should read/write and expose via portCOutput', () {
        io.write(0x08, 0x42);
        expect(io.read(0x08), equals(0x42));
        expect(io.portCOutput, equals(0x42));
      });
    });

    group('Port A (DDA + OPA)', () {
      test('output mode: read returns OPA value', () {
        io.write(0x0C, 0xFF); // DDA = all output.
        io.write(0x0E, 0xAB); // OPA = 0xAB.
        expect(io.read(0x0E), equals(0xAB));
      });

      test('input mode: read returns external pin state', () {
        io.write(0x0C, 0x00); // DDA = all input.
        io.setPortAInput(0xCD);
        expect(io.read(0x0E), equals(0xCD));
      });

      test('mixed mode: output bits from OPA, input bits from pins', () {
        io.write(0x0C, 0xF0); // DDA: high nibble output, low nibble input.
        io.write(0x0E, 0xAB); // OPA = 0xAB.
        io.setPortAInput(0xCD);
        // High nibble: OPA & 0xF0 = 0xA0, Low nibble: pins & 0x0F = 0x0D.
        expect(io.read(0x0E), equals(0xAD));
      });

      test('portAOutput should only return driven bits', () {
        io.write(0x0C, 0xF0); // DDA: high nibble output.
        io.write(0x0E, 0xAB);
        expect(io.portAOutput, equals(0xA0));
      });
    });

    group('Port B (DDB + OPB)', () {
      test('output mode: read returns OPB value', () {
        io.write(0x0D, 0xFF); // DDB = all output.
        io.write(0x0F, 0x55); // OPB = 0x55.
        expect(io.read(0x0F), equals(0x55));
      });

      test('input mode: read returns external pin state', () {
        io.write(0x0D, 0x00); // DDB = all input.
        io.setPortBInput(0x77);
        expect(io.read(0x0F), equals(0x77));
      });

      test('portBOutput should only return driven bits', () {
        io.write(0x0D, 0x0F); // DDB: low nibble output.
        io.write(0x0F, 0xAB);
        expect(io.portBOutput, equals(0x0B));
      });
    });

    group('MSK register (0x0A)', () {
      test('should only store low nibble', () {
        io.write(0x0A, 0xFF);
        expect(io.read(0x0A), equals(0x0F));
      });
    });

    group('IF register (0x0B)', () {
      test('should only allow writing IF0 and IF1', () {
        io.write(0x0B, 0x0F); // Try to write all 4 bits.
        // Only IF0 (bit 0) and IF1 (bit 1) should be set.
        expect(io.read(0x0B), equals(0x03));
      });

      test('read-only bits RD and TD should be set by serial events', () {
        io.serialReceiveComplete(0x42);
        expect(io.read(0x0B) & 0x04, equals(0x04)); // RD set.

        io.serialTransmitComplete();
        expect(io.read(0x0B) & 0x08, equals(0x08)); // TD set.
      });
    });

    group('U register (0x05)', () {
      test('read should return serial data and clear RD flag', () {
        io.serialReceiveComplete(0xAB);
        expect(io.read(0x0B) & 0x04, equals(0x04)); // RD flag set.

        final int data = io.read(0x05);
        expect(data, equals(0xAB));
        expect(io.read(0x0B) & 0x04, equals(0x00)); // RD flag cleared.
      });
    });

    group('Serial transfer (0x06)', () {
      test('write should clear TD flag', () {
        io.serialTransmitComplete(); // Set TD.
        expect(io.read(0x0B) & 0x08, equals(0x08));

        io.write(0x06, 0x42); // Start new transfer.
        expect(io.read(0x0B) & 0x08, equals(0x00)); // TD cleared.
      });
    });

    group('Divider reset (0x04)', () {
      test('write should not affect other registers', () {
        io.serialTransmitComplete(); // Set TD flag.
        io.write(0x04, 0xFF); // Divider reset.
        expect(io.read(0x0B) & 0x08, equals(0x08)); // TD still set.
      });
    });

    group('Interrupts', () {
      test('triggerIRQ should set IF0 and fire callback when MSK0 is set', () {
        io.write(0x0A, 0x01); // Enable IRQ interrupt (MSK0).
        io.triggerIRQ();
        expect(io.read(0x0B) & 0x01, equals(0x01));
        expect(interruptCount, equals(1));
      });

      test('triggerPB7 should set IF1 and fire callback when MSK1 is set', () {
        io.write(0x0A, 0x02); // Enable PB7 interrupt (MSK1).
        io.triggerPB7();
        expect(io.read(0x0B) & 0x02, equals(0x02));
        expect(interruptCount, equals(1));
      });

      test('should not fire callback when interrupt is masked', () {
        io.write(0x0A, 0x00); // All interrupts masked.
        io.triggerIRQ();
        expect(io.read(0x0B) & 0x01, equals(0x01)); // Flag still set.
        expect(interruptCount, equals(0)); // But no callback.
      });

      test('serialReceiveComplete should fire when MSK2 is set', () {
        io.write(0x0A, 0x04); // Enable RD interrupt (MSK2).
        io.serialReceiveComplete(0x00);
        expect(interruptCount, equals(1));
      });

      test('serialTransmitComplete should fire when MSK3 is set', () {
        io.write(0x0A, 0x08); // Enable TD interrupt (MSK3).
        io.serialTransmitComplete();
        expect(interruptCount, equals(1));
      });

      test('enabling mask after flag is set should fire callback', () {
        io.triggerIRQ(); // Set IF0, but MSK0=0 → no interrupt.
        expect(interruptCount, equals(0));
        io.write(0x0A, 0x01); // Now enable MSK0.
        expect(interruptCount, equals(1));
      });
    });

    group('Unimplemented registers', () {
      test('reads from 0x00-0x03 should return 0xFF', () {
        for (int i = 0; i <= 3; i++) {
          expect(io.read(i), equals(0xFF));
        }
      });
    });

    group('saveState / restoreState', () {
      test('round-trip preserves all register state', () {
        io.write(0x08, 0x42); // OPC.
        io.write(0x09, 0xAB); // G.
        io.write(0x0A, 0x0F); // MSK.
        io.write(0x0B, 0x03); // IF (writable bits only).
        io.write(0x0C, 0xF0); // DDA.
        io.write(0x0D, 0x0F); // DDB.
        io.write(0x0E, 0xAA); // OPA.
        io.write(0x0F, 0x55); // OPB.
        io.write(0x07, 0x7F); // F.
        io.serialReceiveComplete(0xCD); // U + RD flag.
        io.setPortAInput(0x11);
        io.setPortBInput(0x22);

        final Map<String, dynamic> state = io.saveState();

        // Create a fresh LH5811 and restore.
        final LH5811 restored = LH5811();
        restored.restoreState(state);

        // Verify all readable registers match.
        expect(restored.read(0x08), equals(io.read(0x08))); // OPC.
        expect(restored.read(0x09), equals(io.read(0x09))); // G.
        expect(restored.read(0x0A), equals(io.read(0x0A))); // MSK.
        expect(restored.read(0x0B), equals(io.read(0x0B))); // IF.
        expect(restored.read(0x0C), equals(io.read(0x0C))); // DDA.
        expect(restored.read(0x0D), equals(io.read(0x0D))); // DDB.
        expect(restored.read(0x07), equals(io.read(0x07))); // F.
        expect(restored.portCOutput, equals(io.portCOutput));
      });

      test('round-trip preserves port output and pin state', () {
        io.write(0x0C, 0xFF); // DDA = all output.
        io.write(0x0E, 0xAA); // OPA.
        io.write(0x0D, 0xFF); // DDB = all output.
        io.write(0x0F, 0x55); // OPB.
        io.setPortAInput(0x11);
        io.setPortBInput(0x22);

        final Map<String, dynamic> state = io.saveState();
        final LH5811 restored = LH5811();
        restored.restoreState(state);

        expect(restored.portAOutput, equals(io.portAOutput));
        expect(restored.portBOutput, equals(io.portBOutput));

        // Switch to input mode and verify pin state preserved.
        restored.write(0x0C, 0x00); // DDA = all input.
        restored.write(0x0D, 0x00); // DDB = all input.
        expect(restored.read(0x0E), equals(0x11)); // pinPA.
        expect(restored.read(0x0F), equals(0x22)); // pinPB.
      });

      test('restoreState does not affect callbacks', () {
        int count = 0;
        final LH5811 target = LH5811(onInterrupt: () => count++);
        target.restoreState(io.saveState());
        target.write(0x0A, 0x01); // Enable MSK0.
        target.triggerIRQ();
        expect(count, equals(1));
      });
    });

    group('Port input providers', () {
      test('onPortBRead should be called when CPU reads PB', () {
        // Simulates keyboard matrix: PA output selects column,
        // PB input returns pressed keys for that column.
        final LH5811 ioWithKeyboard = LH5811(
          onPortBRead: () => 0x42,
        );
        ioWithKeyboard.write(0x0D, 0x00); // DDB = all input.
        expect(ioWithKeyboard.read(0x0F), equals(0x42));
      });

      test('onPortARead should be called when CPU reads PA', () {
        final LH5811 ioWithProvider = LH5811(
          onPortARead: () => 0xCD,
        );
        ioWithProvider.write(0x0C, 0x00); // DDA = all input.
        expect(ioWithProvider.read(0x0E), equals(0xCD));
      });

      test('provider should combine with direction register', () {
        final LH5811 ioMixed = LH5811(
          onPortBRead: () => 0xAB,
        );
        ioMixed.write(0x0D, 0xF0); // DDB: high nibble output.
        ioMixed.write(0x0F, 0x55); // OPB = 0x55.
        // High nibble from OPB (0x50), low nibble from provider (0x0B).
        expect(ioMixed.read(0x0F), equals(0x5B));
      });

      test('setPortBInput still works when no provider is set', () {
        io.write(0x0D, 0x00); // DDB = all input.
        io.setPortBInput(0x77);
        expect(io.read(0x0F), equals(0x77));
      });
    });
  });
}
