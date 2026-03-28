import 'package:basic_compiler/src/tokens.dart';

/// Tokenizes a single BASIC line (the part after the line number) into bytes.
///
/// Keywords are replaced with their 2-byte internal codes. Everything else
/// (variable names, numbers, operators, spaces) is emitted as raw ASCII.
/// String literals (between quotes) are passed through verbatim.
/// After a REM token, the rest of the line is literal ASCII.
/// After a DATA token, everything until `:` or end-of-line is literal ASCII.
List<int> tokenizeLine(String line) {
  final List<int> bytes = <int>[];
  final String upper = line.toUpperCase();
  int pos = 0;

  while (pos < line.length) {
    // String literal — pass through verbatim.
    if (line[pos] == '"') {
      bytes.add(line.codeUnitAt(pos));
      pos++;
      while (pos < line.length && line[pos] != '"') {
        bytes.add(line.codeUnitAt(pos));
        pos++;
      }
      if (pos < line.length) {
        bytes.add(line.codeUnitAt(pos)); // closing quote
        pos++;
      }
      continue;
    }

    // Try longest-match keyword.
    final int? matched = _matchKeyword(upper, pos);
    if (matched != null) {
      final int code = basicTokens[tokensByLength[matched]]!;
      bytes.add((code >> 8) & 0xFF);
      bytes.add(code & 0xFF);
      final int keyLen = tokensByLength[matched].length;
      pos += keyLen;

      // REM: rest of line is literal ASCII.
      if (tokensByLength[matched] == 'REM') {
        while (pos < line.length) {
          bytes.add(line.codeUnitAt(pos));
          pos++;
        }
        break;
      }

      // DATA: literal ASCII until `:` or end-of-line.
      if (tokensByLength[matched] == 'DATA') {
        while (pos < line.length && line[pos] != ':') {
          bytes.add(line.codeUnitAt(pos));
          pos++;
        }
      }

      continue;
    }

    // Default: emit as raw ASCII.
    bytes.add(line.codeUnitAt(pos));
    pos++;
  }

  return bytes;
}

/// Returns the index into [tokensByLength] of the longest keyword matching
/// at [pos] in [upper], or null if no keyword matches.
///
/// A keyword only matches if the character after it is NOT a letter (to
/// avoid matching `TO` inside `TOTAL`, etc.).
int? _matchKeyword(String upper, int pos) {
  for (int i = 0; i < tokensByLength.length; i++) {
    final String keyword = tokensByLength[i];
    if (pos + keyword.length > upper.length) continue;
    if (upper.substring(pos, pos + keyword.length) != keyword) continue;

    // Check word boundary: next char must not be a letter.
    final int after = pos + keyword.length;
    if (after < upper.length) {
      final int ch = upper.codeUnitAt(after);
      // A-Z or a-z or $
      if ((ch >= 0x41 && ch <= 0x5A) ||
          (ch >= 0x61 && ch <= 0x7A) ||
          ch == 0x24) {
        continue;
      }
    }
    return i;
  }
  return null;
}
