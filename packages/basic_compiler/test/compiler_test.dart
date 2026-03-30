import 'dart:io';

import 'package:basic_compiler/basic_compiler.dart';
import 'package:basic_compiler/src/lexer.dart';
import 'package:test/test.dart';

void main() {
  group('tokens', () {
    test('known token values match TRM', () {
      expect(basicTokens['PRINT'], 0xF097);
      expect(basicTokens['GOTO'], 0xF192);
      expect(basicTokens['WAIT'], 0xF1B3);
      expect(basicTokens['END'], 0xF18E);
      expect(basicTokens['IF'], 0xF196);
      expect(basicTokens['THEN'], 0xF1AE);
      expect(basicTokens['FOR'], 0xF1A5);
      expect(basicTokens['NEXT'], 0xF19A);
      expect(basicTokens['GOSUB'], 0xF194);
      expect(basicTokens['RETURN'], 0xF199);
      expect(basicTokens['REM'], 0xF1AB);
    });
  });

  group('lexer', () {
    test('PRINT A', () {
      expect(tokenizeLine('PRINT A'), [0xF0, 0x97, 0x20, 0x41]);
    });

    test('GOTO 100', () {
      expect(
        tokenizeLine('GOTO 100'),
        [0xF1, 0x92, 0x20, 0x31, 0x30, 0x30],
      );
    });

    test('string literal passed verbatim', () {
      final List<int> result = tokenizeLine('PRINT "HELLO"');
      // PRINT token + space + "HELLO"
      expect(result[0], 0xF0);
      expect(result[1], 0x97);
      expect(result[2], 0x20); // space
      expect(result[3], 0x22); // "
      expect(result[4], 0x48); // H
      expect(result[5], 0x45); // E
      expect(result[6], 0x4C); // L
      expect(result[7], 0x4C); // L
      expect(result[8], 0x4F); // O
      expect(result[9], 0x22); // "
    });

    test('REM preserves rest as literal ASCII', () {
      final List<int> result = tokenizeLine('REM THIS IS A COMMENT');
      expect(result[0], 0xF1); // REM high byte
      expect(result[1], 0xAB); // REM low byte
      // Rest is ASCII for " THIS IS A COMMENT"
      expect(result.length, 2 + ' THIS IS A COMMENT'.length);
    });

    test('does not match keyword inside variable name', () {
      // TOTAL should not match TO
      final List<int> result = tokenizeLine('PRINT TOTAL');
      // PRINT token + space + T O T A L as ASCII
      expect(result[0], 0xF0);
      expect(result[1], 0x97);
      expect(result[2], 0x20); // space
      expect(result[3], 0x54); // T
      expect(result[4], 0x4F); // O
      expect(result[5], 0x54); // T
      expect(result[6], 0x41); // A
      expect(result[7], 0x4C); // L
    });

    test('IF THEN with expression', () {
      final List<int> result = tokenizeLine('IF A>1 THEN GOTO 50');
      expect(result[0], 0xF1); // IF
      expect(result[1], 0x96);
      // " A>1 " as ASCII
      expect(result[2], 0x20); // space
      expect(result[3], 0x41); // A
      expect(result[4], 0x3E); // >
      expect(result[5], 0x31); // 1
      expect(result[6], 0x20); // space
      expect(result[7], 0xF1); // THEN
      expect(result[8], 0xAE);
      expect(result[9], 0x20); // space
      expect(result[10], 0xF1); // GOTO
      expect(result[11], 0x92);
      expect(result[12], 0x20); // space
      expect(result[13], 0x35); // 5
      expect(result[14], 0x30); // 0
    });
  });

  group('compiler', () {
    test('TRM example: 10 PRINT A / 20 END', () {
      final CompilerResult result = compile('10 PRINT A\n20 END');

      expect(result.lineCount, 2);

      // Verify byte-by-byte:
      // Line 10: num=0x000A, code="PRINT A" -> [F0,97,20,41], len=5
      // Line 20: num=0x0014, code="END" -> [F1,8E], len=3
      expect(result.bytes[0], 0x00); // line 10 high
      expect(result.bytes[1], 0x0A); // line 10 low
      expect(result.bytes[2], 5); // length: 4 tokenized + 1 CR
      expect(result.bytes[3], 0xF0); // PRINT high
      expect(result.bytes[4], 0x97); // PRINT low
      expect(result.bytes[5], 0x20); // space
      expect(result.bytes[6], 0x41); // A
      expect(result.bytes[7], 0x0D); // CR

      expect(result.bytes[8], 0x00); // line 20 high
      expect(result.bytes[9], 0x14); // line 20 low
      expect(result.bytes[10], 3); // length: 2 tokenized + 1 CR
      expect(result.bytes[11], 0xF1); // END high
      expect(result.bytes[12], 0x8E); // END low
      expect(result.bytes[13], 0x0D); // CR

      expect(result.bytes[14], 0xFF); // end of program
      expect(result.bytes.length, 15);
    });

    test('skips blank lines', () {
      final CompilerResult result = compile('10 END\n\n');
      expect(result.lineCount, 1);
    });

    test('rejects non-ascending line numbers', () {
      expect(
        () => compile('20 END\n10 PRINT A'),
        throwsA(isA<CompilerError>()),
      );
    });

    test('rejects missing statement', () {
      expect(
        () => compile('10'),
        throwsA(isA<CompilerError>()),
      );
    });

    test('FOR/NEXT loop', () {
      final CompilerResult result = compile(
        '10 FOR I=1 TO 10\n20 PRINT I\n30 NEXT I',
      );
      expect(result.lineCount, 3);
      expect(result.bytes.last, 0xFF);
    });

    test('housepic.bas compiles successfully', () {
      final String source = File(
        'test/samples/housepic.bas',
      ).readAsStringSync();
      final CompilerResult result = compile(source);

      expect(result.lineCount, 51);
      expect(result.bytes.last, 0xFF);

      // Verify structure: every line must have valid header.
      int offset = 0;
      int lineCount = 0;
      int lastLineNum = -1;
      while (offset < result.bytes.length - 1) {
        final int lineNum =
            (result.bytes[offset] << 8) | result.bytes[offset + 1];
        final int length = result.bytes[offset + 2];
        expect(lineNum, greaterThan(lastLineNum), reason: 'line $lineNum');
        expect(length, greaterThan(0), reason: 'line $lineNum length');
        // Last byte of line data must be 0x0D (CR).
        expect(
          result.bytes[offset + 2 + length],
          0x0D,
          reason: 'line $lineNum missing CR',
        );
        lastLineNum = lineNum;
        offset += 3 + length;
        lineCount++;
      }
      expect(lineCount, result.lineCount);
      expect(result.bytes[offset], 0xFF);
    });

    test('DATA lines preserve literal content', () {
      final CompilerResult result = compile(
        '1 DATA 10,20,30\n2 END',
      );
      expect(result.lineCount, 2);
      // DATA token followed by literal " 10,20,30"
      final int dataHi = result.bytes[3];
      final int dataLo = result.bytes[4];
      expect(dataHi, basicTokens['DATA']! >> 8);
      expect(dataLo, basicTokens['DATA']! & 0xFF);
    });

    test('GOSUB with string label', () {
      final CompilerResult result = compile(
        '10 GOSUB"HOUSE"\n20 END',
      );
      expect(result.lineCount, 2);
      // GOSUB token + "HOUSE"
      expect(result.bytes[3], basicTokens['GOSUB']! >> 8);
      expect(result.bytes[4], basicTokens['GOSUB']! & 0xFF);
      expect(result.bytes[5], 0x22); // opening "
    });

    test('celsius_conversion.bas compiles successfully', () {
      final String source = File(
        'test/samples/celsius_conversion.bas',
      ).readAsStringSync();
      final CompilerResult result = compile(source);
      expect(result.lineCount, 5);
      expect(result.bytes.last, 0xFF);
    });

    test('lcd_invert.bas compiles successfully', () {
      final String source = File(
        'test/samples/lcd_invert.bas',
      ).readAsStringSync();
      final CompilerResult result = compile(source);
      expect(result.lineCount, 15);
      expect(result.bytes.last, 0xFF);
    });

    test('multiple statements with colon', () {
      final CompilerResult result = compile(
        '10 YS=0:SP=20:GRAPH:COLOR 2',
      );
      expect(result.lineCount, 1);
      expect(result.bytes.last, 0xFF);
    });
  });
}
