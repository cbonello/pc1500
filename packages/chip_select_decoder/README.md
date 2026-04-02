# chip_select_decoder

Hardware chip-select decoder for the Sharp PC-1500 pocket computer.

Manages the mapping of physical memory chips (ROM and RAM) across two 64KB
address banks (ME0, ME1). Provides O(1) read/write access via internal lookup
tables and detects address overlaps when chips are registered.

## Key classes

- `ChipSelectDecoder` - Main decoder; register ROM/RAM chips, read/write by address.
- `MemoryChipRam` - Writable RAM chip with state serialization.
- `MemoryChipRom` - Read-only ROM chip with hash-based identity.
- `MemoryBank` - Enum distinguishing ME0 and ME1.

## State persistence

RAM chip contents can be saved and restored for emulator state snapshots:

```dart
final state = decoder.saveState();   // Map<String, dynamic>
decoder.restoreState(state);         // Restores RAM contents.
```

ROM chips are validated by hash on restore to prevent loading incompatible states.

## Usage

```dart
import 'package:chip_select_decoder/chip_select_decoder.dart';

final csd = ChipSelectDecoder();

// Register a 16KB ROM at C000H in ME0.
csd.appendROM(MemoryBank.me0, 0xC000, romBytes);

// Register 2KB user RAM at 4000H in ME0.
csd.appendRAM(MemoryBank.me0, 0x4000, 0x0800);

// Read/write.
final value = csd.readByteAt(0xC000);  // ROM read.
csd.writeByteAt(0x4000, 0x42);         // RAM write.
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/cbonello/pc1500/issues
