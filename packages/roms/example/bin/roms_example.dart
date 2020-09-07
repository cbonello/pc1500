// ignore_for_file: avoid_print

import 'package:annotations/annotations.dart';
import 'package:roms/roms.dart';

void main() {
  final CE150Rom rom = CE150Rom(CE150RomType.version_1);
  final MemoryBanksAnnotations annotations = MemoryBanksAnnotations();
  annotations.load(rom.annotations);

  // ROM marker is at offset 0x800.
  final int romMarker = rom.bytes[0x800];
  final String hex =
      romMarker.toUnsigned(8).toRadixString(16).padLeft(2, '0').toUpperCase();

  // CE-150 ROM is loaded at address 0xA000 in PC-1500 ME0 memory bank.
  final DataAnnotation annotation =
      annotations.getAnnotationFromAddress(0xA800) as DataAnnotation;
  print('A800  ${annotation.label}:  ${hex}H  ; ${annotation.comment}');
}
