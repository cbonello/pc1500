import 'dart:typed_data';

import 'package:basic_compiler/src/lexer.dart';

/// Result of compiling a BASIC program.
class CompilerResult {
  const CompilerResult({
    required this.bytes,
    required this.lineCount,
  });

  /// The compiled binary blob, ready to write to emulator RAM.
  final Uint8List bytes;

  /// Number of BASIC lines compiled.
  final int lineCount;
}

/// Error encountered during compilation.
class CompilerError implements Exception {
  const CompilerError(this.line, this.message);

  /// 1-based source line number where the error occurred.
  final int line;

  /// Human-readable error description.
  final String message;

  @override
  String toString() => 'Line $line: $message';
}

/// Compiles BASIC source text into the PC-1500 binary program format.
///
/// The output is a [Uint8List] containing:
/// - For each line: 2-byte line number (big-endian) + 1-byte length +
///   tokenized program code + 0x0D (CR)
/// - A final 0xFF end-of-program sentinel
///
/// Throws [CompilerError] on invalid input.
CompilerResult compile(String source) {
  final List<String> sourceLines = source.split('\n');
  final List<int> output = <int>[];
  int lastLineNum = -1;
  int lineCount = 0;

  for (int i = 0; i < sourceLines.length; i++) {
    final String raw = sourceLines[i].trim();
    if (raw.isEmpty) continue;

    // Parse line number.
    final int spaceIdx = raw.indexOf(' ');
    if (spaceIdx == -1) {
      throw CompilerError(i + 1, 'Missing BASIC statement after line number');
    }

    final String numStr = raw.substring(0, spaceIdx);
    final int? lineNum = int.tryParse(numStr);
    if (lineNum == null || lineNum < 1 || lineNum > 65279) {
      throw CompilerError(i + 1, 'Invalid line number: $numStr');
    }
    if (lineNum <= lastLineNum) {
      throw CompilerError(
        i + 1,
        'Line number $lineNum must be greater than $lastLineNum',
      );
    }
    lastLineNum = lineNum;

    // Tokenize the BASIC code after the line number.
    final String code = raw.substring(spaceIdx + 1);
    final List<int> tokenized = tokenizeLine(code);

    // Length = tokenized bytes + 1 for the 0x0D terminator.
    final int length = tokenized.length + 1;
    if (length > 255) {
      throw CompilerError(i + 1, 'Line too long ($length bytes)');
    }

    // Emit: line number (big-endian) + length + tokenized + CR.
    output.add((lineNum >> 8) & 0xFF);
    output.add(lineNum & 0xFF);
    output.add(length);
    output.addAll(tokenized);
    output.add(0x0D);

    lineCount++;
  }

  // End-of-program sentinel.
  output.add(0xFF);

  return CompilerResult(
    bytes: Uint8List.fromList(output),
    lineCount: lineCount,
  );
}
