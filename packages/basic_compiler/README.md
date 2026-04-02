# basic_compiler

BASIC tokenizer/compiler for the Sharp PC-1500 pocket computer.

Converts BASIC source code into the PC-1500's internal binary format, ready
for upload to emulator RAM at $40C2. Tokenizes keywords (PRINT, GOTO, IF,
etc.) into their single- or two-byte token codes per the PC-1500 ROM table.

## Output format

Each compiled line:
```
[2-byte line number (big-endian)] [1-byte length] [tokenized data...] [0x0D]
```
The program ends with a `0xFF` sentinel byte.

## Usage

```dart
import 'package:basic_compiler/basic_compiler.dart';

final result = compile('10 PRINT "HELLO"\n20 GOTO 10');
print('${result.lineCount} lines, ${result.bytes.length} bytes');

// result.bytes is a Uint8List ready to write at $40C2.
```

Throws `CompilerError` on invalid input:

```dart
try {
  compile('10');  // Missing statement.
} on CompilerError catch (e) {
  print('Line ${e.line}: ${e.message}');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/cbonello/pc1500/issues
