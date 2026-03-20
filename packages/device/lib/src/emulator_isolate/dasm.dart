import 'dart:typed_data';

import 'package:lh5801/lh5801.dart';

/// Base class for disassembly output descriptors.
///
/// Each descriptor represents one entry in a disassembly listing — either
/// a decoded [DasmCode] instruction or a raw [DasmData] byte block.
abstract class DasmDescriptor {
  const DasmDescriptor({required this.label, required this.comment});

  /// Optional symbolic label (e.g. `BASINPUT1`).
  final String label;

  /// Optional end-of-line comment (e.g. `; clear display`).
  final String comment;

  /// Formats this descriptor as a human-readable disassembly line.
  ///
  /// [format] selects the numeric radix (hex, decimal, binary).
  /// [suffix] appends a radix suffix (e.g. `H` for hex).
  /// [displayComment] controls whether [comment] is included.
  String dump({
    Radix format = Radix.hexadecimal,
    bool suffix = false,
    bool displayComment = true,
  });
}

/// A disassembled CPU instruction.
class DasmCode extends DasmDescriptor {
  const DasmCode({
    super.label = '',
    required this.instruction,
    super.comment = '',
  });

  /// The decoded LH5801 instruction.
  final Instruction instruction;

  @override
  String dump({
    Radix format = Radix.hexadecimal,
    bool suffix = false,
    bool displayComment = true,
  }) {
    final StringBuffer output = StringBuffer();
    final String addr = instruction.addressToString(
      radix: format,
      suffix: suffix,
    );

    if (label.isNotEmpty) {
      output.writeln('$addr  $label:');
    }
    output.write('$addr  ');
    output.write(
      '${instruction.bytesToString(radix: format, suffix: suffix)}  ',
    );
    output.write(
      instruction.instructionToString(radix: format, suffix: suffix),
    );
    if (comment.isNotEmpty && displayComment) {
      output.write('  $comment');
    }
    output.writeln();

    return output.toString();
  }
}

/// A raw data block in the disassembly (`.db` directive).
class DasmData extends DasmDescriptor {
  DasmData({
    required this.address,
    super.label = '',
    required this.data,
    super.comment = '',
  }) : assert(address <= 0x1FFFF),
       assert(data.isNotEmpty);

  /// Start address of the data block (17-bit LH5801 address space).
  final int address;

  /// Raw byte values.
  final Uint8List data;

  @override
  String dump({
    Radix format = Radix.hexadecimal,
    bool suffix = false,
    bool displayComment = true,
  }) {
    final StringBuffer output = StringBuffer();
    final String addr = OperandDump.op16(
      address,
      radix: format,
      suffix: suffix,
    );

    if (label.isNotEmpty) {
      output.writeln('$addr  $label:');
    }
    output.write('$addr  .db');
    for (int i = 0; i < data.length; i++) {
      output.write(
        ' ${OperandDump.op8(data[i], radix: format, suffix: suffix)}',
      );
    }
    output.writeln();

    return output.toString();
  }
}
