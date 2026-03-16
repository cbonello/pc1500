Sharp PC-1500 pocket computer emulator.

Orchestrates the LH5801 CPU, chip select decoder, LCD driver, and I/O port
controller into a complete emulated system. Runs the emulator in a separate
isolate and communicates with the UI via message passing.

## Architecture

```
┌─────────────────────────────────────────────┐
│  UI Isolate                                 │
│  Device ←──── LcdEvent stream               │
│    │                                        │
│    │ SendPort / ReceivePort                 │
│    ▼                                        │
│  Emulator Isolate                           │
│  ┌────────────────────────────────────────┐ │
│  │ Emulator                               │ │
│  │  ├── LH5801 CPU                        │ │
│  │  ├── ChipSelectDecoder (ME0 + ME1)     │ │
│  │  ├── Lcd (display buffer observer)     │ │
│  │  ├── MemoryBanksAnnotations            │ │
│  │  └── LH5801DASM (disassembler)         │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## Memory map (ME0)

| Address         | Content                          |
|-----------------|----------------------------------|
| 0000H - 3FFFH   | Option user memory (CE-160)     |
| 4000H - 47FFH   | Standard user RAM (2KB)         |
| 4800H - 5FFFH   | Optional RAM (CE-151 / CE-155)  |
| 7600H - 7BFFH   | Standard user & system RAM      |
| C000H - FFFFH   | System ROM (16KB)               |

## Usage

```dart
import 'package:device/device.dart';

final Device device = Device(
  type: HardwareDeviceType.pc1500,
  debugPort: 3756,
);

// Start the emulator isolate.
await device.run();

// Listen for LCD updates.
device.lcdEvents.listen((event) {
  // Render display buffers and symbols.
});

// Change hardware type (restarts the emulator).
device.updateHardwareDeviceType(HardwareDeviceType.pc1500A);

// Stop the emulator.
device.kill();
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/cbonello/pc1500/issues
