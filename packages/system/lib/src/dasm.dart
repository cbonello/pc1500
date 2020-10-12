import 'dart:typed_data';

import 'package:lh5801/lh5801.dart';
import 'package:meta/meta.dart';

abstract class DasmDescriptor {
  const DasmDescriptor({@required this.label, @required this.comment})
      : assert(label != null),
        assert(comment != null);

  final String label;
  final String comment;

  String dump({Radix format, bool suffix = false, bool displayComment = true});
}

class DasmCode extends DasmDescriptor {
  const DasmCode({String label, @required this.instruction, String comment})
      : assert(instruction != null),
        super(label: label ?? '', comment: comment ?? '');

  final Instruction instruction;

  @override
  String dump({Radix format, bool suffix = false, bool displayComment = true}) {
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
      output.write(
        '  $comment',
      );
    }
    output.writeln();
    return output.toString();
  }
}

class DasmData extends DasmDescriptor {
  DasmData({
    @required this.address,
    String label,
    @required this.data,
    String comment,
  })  : assert(address != null && address < 0x1FFFF),
        assert(data != null && data.isNotEmpty),
        super(label: label ?? '', comment: comment ?? '');

  final int address;
  final Uint8List data;

  @override
  String dump({Radix format, bool suffix = false, bool displayComment = true}) {
    final StringBuffer output = StringBuffer();
    final String addr = OperandDump.op16(
      address,
      radix: format,
      suffix: suffix,
    );

    if (label.isNotEmpty) {
      output.writeln('$addr  $label:');
    }
    output.write('$addr  .db ');
    for (int i = 0; i < data.length; i += 8) {
      if (i < data.length) {
        output.write(
          ' ${OperandDump.op8(data[i], radix: format, suffix: suffix)}',
        );
      }
    }
    output.writeln();
    return output.toString();
  }
}
