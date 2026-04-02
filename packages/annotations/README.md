# annotations

Code and data annotations for Sharp PC-1500 ROM/RAM memory locations.

Provides a structured way to label and describe memory addresses across the
PC-1500's two memory banks (ME0, ME1). Used by the disassembler and debugger
to display human-readable names for ROM subroutines, system variables, and
I/O ports.

## Key classes

- `MemoryBanksAnnotations` - Main container; loads annotations from JSON and
  provides lookup by address or symbol name.
- `CodeAnnotation` - Marks a code region with a label and optional comment.
- `DataAnnotation` - Marks a data region with a label, size, and optional comment.
- `AnnotatedArea` - Groups contiguous annotations into logical areas.

## Usage

```dart
import 'package:annotations/annotations.dart';

final annotations = MemoryBanksAnnotations();
annotations.load(someAnnotationsJson);

// Lookup by address.
final label = annotations.getAnnotationFromAddress(0xC000);

// Lookup by symbol name.
final addr = annotations.getAddressFromLabel('MAIN_LOOP');
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/cbonello/pc1500/issues
