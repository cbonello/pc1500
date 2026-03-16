Sharp PC-1500 and CE-150 ROMs.

Available ROMs:

- PC-1500 version A03
- CE-150 version 1

This software is made available for documentation purpose only since the PC-1500 is
now an obsolete computer. If you own a copyright on part of this code and do not want
it to be available from here, please inform me.

## Usage

```dart
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
  final AnnotationBase? annotation =
      annotations.getAnnotationFromAddress(0xA800);
  if (annotation case final DataAnnotation data) {
    print('A800  ${data.label}:  ${hex}H  ; ${data.comment}');
  }
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/cbonello/pc1500/issues
