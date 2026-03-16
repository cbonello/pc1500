LCD driver for the Sharp PC-1500 pocket computer.

Emulates the 7x156 dot LF8082GE display by observing writes to the display
buffer RAM (7600H-764FH and 7700H-774DH) and emitting debounced `LcdEvent`
snapshots.

## Memory layout

| Address       | Description                                           |
|---------------|-------------------------------------------------------|
| 7600H - 764DH | Display Buffer #1 (78 bytes)                         |
| 764EH         | LCDSYM1 — DEF, I, II, III, SMALL, SML, SHIFT, BUSY  |
| 764FH         | LCDSYM2 — RUN, PRO, RESERVE, RAD, G, DE             |
| 7700H - 774DH | Display Buffer #2 (78 bytes)                         |

## Usage

```dart
import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:lcd/lcd.dart';

// Create the LCD driver with a memory read function.
final Lcd lcd = Lcd(memRead: chipSelectDecoder.readAt);

// Register as a memory observer for writes to the display RAM.
displayRam.registerObserver(MemoryAccessType.write, lcd);

// Subscribe to LCD events, then request the initial state.
lcd.events.listen((LcdEvent event) {
  // Render event.displayBuffer1, event.displayBuffer2, event.symbols.
});
lcd.emitInitialState();

// Clean up.
lcd.dispose();
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/cbonello/pc1500/issues
