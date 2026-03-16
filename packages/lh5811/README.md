LH5810/LH5811 I/O port controller emulator for the Sharp PC-1500 pocket computer.

## Register map

| Offset | Register | RS3-RS0 | Description |
|--------|----------|---------|-------------|
| 0x04 | Divider Reset | 0100 | Reset internal clock divider |
| 0x05 | U | 0101 | Serial receive data (read clears RD flag) |
| 0x06 | Serial Xfer | 0110 | Load serial data (write clears TD flag) |
| 0x07 | F | 0111 | Modulation clock configuration |
| 0x08 | OPC | 1000 | Port C output |
| 0x09 | G | 1001 | Clock rate / wait time configuration |
| 0x0A | MSK | 1010 | Interrupt mask (IRQ, PB7, RD, TD) |
| 0x0B | IF | 1011 | Interrupt flags (IF0/IF1 writable, RD/TD read-only) |
| 0x0C | DDA | 1100 | Port A direction (0=input, 1=output) |
| 0x0D | DDB | 1101 | Port B direction (0=input, 1=output) |
| 0x0E | OPA | 1110 | Port A data |
| 0x0F | OPB | 1111 | Port B data |

## Usage

```dart
import 'package:lh5811/lh5811.dart';

// Basic setup with interrupt handler.
final LH5811 io = LH5811(onInterrupt: () {
  // Handle interrupt — signal the CPU.
});

// Configure port A as output and write data.
io.write(0x0C, 0xFF);  // DDA: all output.
io.write(0x0E, 0x42);  // OPA: drive 0x42 on PA pins.

// Configure port B as input and read external state.
io.write(0x0D, 0x00);   // DDB: all input.
io.setPortBInput(0xAB); // External hardware drives PB pins.
final int pb = io.read(0x0F); // Returns 0xAB.

// Enable IRQ interrupt and trigger it.
io.write(0x0A, 0x01);  // MSK: enable IRQ.
io.triggerIRQ();        // Sets IF0, fires onInterrupt callback.
```

### Keyboard matrix integration

Port input providers allow external hardware to supply pin state lazily at
read time — ideal for keyboard scanning where PA selects a column and PB
returns the pressed keys for that column.

```dart
final LH5811 io = LH5811(
  onPortBRead: () => keyboardMatrix.scan(io.portAOutput),
  onInterrupt: () => cpu.requestInterrupt(),
);
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/cbonello/pc1500/issues
