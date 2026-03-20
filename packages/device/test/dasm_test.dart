import 'dart:typed_data';

import 'package:device/src/emulator_isolate/dasm.dart';
import 'package:lh5801/lh5801.dart';
import 'package:test/test.dart';

/// Disassembles [bytes] at [address] to produce a real [Instruction].
Instruction _disassemble({
  int address = 0xC000,
  required List<int> bytes,
}) {
  final LH5801DASM dasm = LH5801DASM(
    memRead: (int addr) => addr < address || addr >= address + bytes.length
        ? 0
        : bytes[addr - address],
  );
  return dasm.dump(address);
}

void main() {
  group('DasmCode', () {
    group('dump()', () {
      test('should format instruction without label or comment', () {
        // B5 42 = LDI A, $42
        final DasmCode code = DasmCode(
          instruction: _disassemble(bytes: [0xB5, 0x42]),
        );
        final String result = code.dump();
        expect(result, contains('C000'));
        expect(result, contains('B5 42'));
        expect(result, isNot(contains(':')));
      });

      test('should include label on a separate line', () {
        final DasmCode code = DasmCode(
          label: 'MAIN',
          instruction: _disassemble(bytes: [0xB5, 0x42]),
        );
        final String result = code.dump();
        final List<String> lines = result.trimRight().split('\n');
        expect(lines.length, equals(2));
        expect(lines[0], contains('MAIN:'));
        expect(lines[1], contains('B5 42'));
      });

      test('should include comment when displayComment is true', () {
        final DasmCode code = DasmCode(
          instruction: _disassemble(bytes: [0xB5, 0x42]),
          comment: '; load A',
        );
        expect(code.dump(), contains('; load A'));
      });

      test('should suppress comment when displayComment is false', () {
        final DasmCode code = DasmCode(
          instruction: _disassemble(bytes: [0xB5, 0x42]),
          comment: '; load A',
        );
        expect(code.dump(displayComment: false), isNot(contains('; load A')));
      });

      test('should format in decimal when requested', () {
        final DasmCode code = DasmCode(
          instruction: _disassemble(address: 100, bytes: [0xB5, 0x42]),
        );
        final String result = code.dump(format: Radix.decimal);
        expect(result, contains('100'));
      });
    });
  });

  group('DasmData', () {
    group('constructor', () {
      test('should accept address 0x00000', () {
        expect(
          () => DasmData(address: 0x00000, data: Uint8List.fromList([0])),
          returnsNormally,
        );
      });

      test('should accept max address 0x1FFFF', () {
        expect(
          () => DasmData(address: 0x1FFFF, data: Uint8List.fromList([0])),
          returnsNormally,
        );
      });

      test('should reject address above 0x1FFFF', () {
        expect(
          () => DasmData(address: 0x20000, data: Uint8List.fromList([0])),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should reject empty data', () {
        expect(
          () => DasmData(address: 0, data: Uint8List(0)),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('dump()', () {
      test('should format single byte', () {
        final DasmData data = DasmData(
          address: 0x7600,
          data: Uint8List.fromList([0xFF]),
        );
        final String result = data.dump();
        expect(result, contains('7600'));
        expect(result, contains('.db'));
        expect(result, contains('FF'));
      });

      test('should format all bytes (not skip any)', () {
        final DasmData data = DasmData(
          address: 0x4000,
          data: Uint8List.fromList([
            0x00, 0x0A, 0x04, 0xF0, 0x97, 0x37, 0x0D, 0xFF,
            0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
          ]),
        );
        final String result = data.dump();
        // All 16 bytes must appear.
        expect(result, contains('0A'));
        expect(result, contains('F0'));
        expect(result, contains('97'));
        expect(result, contains('FF'));
        expect(result, contains('08'));
        // Count hex byte tokens in the .db line.
        final String dbLine = result.split('\n').firstWhere(
          (String l) => l.contains('.db'),
        );
        final int byteCount = dbLine.split('.db')[1].trim().split(' ').length;
        expect(byteCount, equals(16));
      });

      test('should include label on a separate line', () {
        final DasmData data = DasmData(
          address: 0xC100,
          label: 'KEYWORDS',
          data: Uint8List.fromList([0x44, 0x41]),
        );
        final String result = data.dump();
        final List<String> lines = result.trimRight().split('\n');
        expect(lines.length, equals(2));
        expect(lines[0], contains('KEYWORDS:'));
        expect(lines[1], contains('.db'));
      });

      test('should not include label line when label is empty', () {
        final DasmData data = DasmData(
          address: 0x4000,
          data: Uint8List.fromList([0x01]),
        );
        final String result = data.dump();
        expect(result.trimRight().split('\n').length, equals(1));
      });

      test('should format in decimal when requested', () {
        final DasmData data = DasmData(
          address: 0x4000,
          data: Uint8List.fromList([255]),
        );
        final String result = data.dump(format: Radix.decimal);
        expect(result, contains('255'));
      });
    });
  });
}
