/// PC-1500 keyboard matrix emulator.
///
/// The keyboard uses the CE-153 LH5811 I/O port controller at ME1 0x8000.
/// Key scanning works by:
/// 1. CPU writes to PB2-PB7 (strobe lines, active low) for rows 0-9
/// 2. CPU writes to PC0-PC5 (strobe lines, active low) for rows A-F
/// 3. CPU reads PA0-PA7 and PB0-PB1 (input lines)
///
/// The key code chart (p.109 Technical Reference Manual) encodes each key as:
///   high nibble (0-5) = column, mapped to strobe lines
///   low nibble (0-F) = row, mapped to input lines
///
/// For rows 0-7: strobe is PB(column+2), input is PA(row)
/// For rows 8-9: strobe is PB(column+2), input is PB(row-8)
/// For rows A-F: strobe is PC(column), input is PA(row-10)
///
/// The ON key is NOT in the CE-153 matrix. It connects to PB7 of the
/// PC-1500 main I/O at 0xF000 (see p.105).
class Keyboard {
  /// Set of currently pressed key names.
  final Set<String> _pressedKeys = <String>{};

  /// Press a key by name (e.g. 'a', 'enter', 'f1').
  void keyDown(String keyName) => _pressedKeys.add(keyName);

  /// Release a key by name.
  void keyUp(String keyName) => _pressedKeys.remove(keyName);

  /// Returns true if the ON key is currently pressed.
  bool get isOnKeyPressed => _pressedKeys.contains('on');

  /// Scans the keyboard matrix and returns the PA input byte.
  ///
  /// [strobePB] is the CE-153 PB output (bits 2-7 are strobe lines).
  /// [strobePC] is the CE-153 PC output (bits 0-7 are strobe lines).
  /// Returns PA0-PA7 input state (active low: 0 = key pressed).
  int scanPortA(int strobePB, int strobePC) {
    int result = 0xFF; // All high = no keys pressed.

    for (final String key in _pressedKeys) {
      final _KeyPosition? pos = _keyMap[key];
      if (pos == null) continue;

      if (pos.row < 8) {
        // Rows 0-7: strobe via PB(column+2), input on PA(row).
        if (_isPBStrobeActive(pos.column, strobePB)) {
          result &= ~(1 << pos.row);
        }
      } else if (pos.row >= 10) {
        // Rows A-F (10-15): strobe via PC(column), input on PA(row-10).
        if (_isPCStrobeActive(pos.column, strobePC)) {
          result &= ~(1 << (pos.row - 10));
        }
      }
      // Rows 8-9 are PB inputs, handled by scanPortB.
    }

    return result;
  }

  /// Scans the keyboard matrix and returns the PB input byte.
  ///
  /// Only bits 0-1 are key inputs (PB0, PB1). Bits 2-7 are strobe outputs.
  int scanPortB(int strobePB, int strobePC) {
    int result = 0xFF;

    for (final String key in _pressedKeys) {
      final _KeyPosition? pos = _keyMap[key];
      if (pos == null) continue;

      // Only rows 8-9 map to PB0-PB1 inputs.
      if (pos.row == 8 || pos.row == 9) {
        if (_isPBStrobeActive(pos.column, strobePB)) {
          result &= ~(1 << (pos.row - 8));
        }
      }
    }

    return result;
  }

  /// Checks if a PB strobe line is active (low) for the given column.
  /// Column 0 = PB2, column 1 = PB3, ..., column 5 = PB7.
  bool _isPBStrobeActive(int column, int strobePB) {
    return (strobePB & (1 << (column + 2))) == 0;
  }

  /// Checks if a PC strobe line is active (low) for the given column.
  /// Column 0 = PC0, column 1 = PC1, ..., column 5 = PC5.
  bool _isPCStrobeActive(int column, int strobePC) {
    return (strobePC & (1 << column)) == 0;
  }
}

class _KeyPosition {
  const _KeyPosition(this.column, this.row);
  final int column; // Key code high nibble (0-5).
  final int row; // Key code low nibble (0-15, i.e. 0x0-0xF).
}

/// Key matrix mapping from skin key names to key code positions.
///
/// Derived from the key code chart on p.109 of the Technical Reference Manual.
/// Key code = (column << 4) | row.
const Map<String, _KeyPosition> _keyMap = <String, _KeyPosition>{
  // Column 0 (key codes 0x00-0x0F, PB2 strobe / PC0 strobe)
  'shift': _KeyPosition(0, 1), // 0x01
  'small': _KeyPosition(0, 2), // 0x02
  'mode': _KeyPosition(0, 3), // 0x03
  'up-down': _KeyPosition(0, 4), // 0x04
  'recall': _KeyPosition(0, 5), // 0x05
  'left': _KeyPosition(0, 8), // 0x08 — ◄
  'up': _KeyPosition(0, 10), // 0x0A — ↑
  'down': _KeyPosition(0, 11), // 0x0B — ↓
  'right': _KeyPosition(0, 12), // 0x0C — ►
  'enter': _KeyPosition(0, 13), // 0x0D
  'off': _KeyPosition(0, 15), // 0x0F

  // Column 1 (key codes 0x10-0x1F, PB3 strobe / PC1 strobe)
  'f1': _KeyPosition(1, 1), // 0x11
  'f2': _KeyPosition(1, 2), // 0x12
  'f3': _KeyPosition(1, 3), // 0x13
  'f4': _KeyPosition(1, 4), // 0x14
  'f5': _KeyPosition(1, 5), // 0x15
  'f6': _KeyPosition(1, 6), // 0x16
  'clear': _KeyPosition(1, 8), // 0x18 — CL
  '*': _KeyPosition(1, 10), // 0x1A
  'def': _KeyPosition(1, 11), // 0x1B

  // Column 2 (key codes 0x20-0x2F, PB4 strobe / PC2 strobe)
  ' ': _KeyPosition(2, 0), // 0x20 — SPACE
  '(': _KeyPosition(2, 8), // 0x28
  ')': _KeyPosition(2, 9), // 0x29
  '+': _KeyPosition(2, 11), // 0x2B
  '-': _KeyPosition(2, 13), // 0x2D
  '.': _KeyPosition(2, 14), // 0x2E
  '/': _KeyPosition(2, 15), // 0x2F

  // Column 3 (key codes 0x30-0x3F, PB5 strobe / PC3 strobe)
  '0': _KeyPosition(3, 0), // 0x30
  '1': _KeyPosition(3, 1), // 0x31
  '2': _KeyPosition(3, 2), // 0x32
  '3': _KeyPosition(3, 3), // 0x33
  '4': _KeyPosition(3, 4), // 0x34
  '5': _KeyPosition(3, 5), // 0x35
  '6': _KeyPosition(3, 6), // 0x36
  '7': _KeyPosition(3, 7), // 0x37
  '8': _KeyPosition(3, 8), // 0x38
  '9': _KeyPosition(3, 9), // 0x39
  '=': _KeyPosition(3, 13), // 0x3D

  // Column 4 (key codes 0x40-0x4F, PB6 strobe / PC4 strobe)
  'a': _KeyPosition(4, 1), // 0x41
  'b': _KeyPosition(4, 2), // 0x42
  'c': _KeyPosition(4, 3), // 0x43
  'd': _KeyPosition(4, 4), // 0x44
  'e': _KeyPosition(4, 5), // 0x45
  'f': _KeyPosition(4, 6), // 0x46
  'g': _KeyPosition(4, 7), // 0x47
  'h': _KeyPosition(4, 8), // 0x48
  'i': _KeyPosition(4, 9), // 0x49
  'j': _KeyPosition(4, 10), // 0x4A
  'k': _KeyPosition(4, 11), // 0x4B
  'l': _KeyPosition(4, 12), // 0x4C
  'm': _KeyPosition(4, 13), // 0x4D
  'n': _KeyPosition(4, 14), // 0x4E
  'o': _KeyPosition(4, 15), // 0x4F

  // Column 5 (key codes 0x50-0x5F, PB7 strobe / PC5 strobe)
  'p': _KeyPosition(5, 0), // 0x50
  'q': _KeyPosition(5, 1), // 0x51
  'r': _KeyPosition(5, 2), // 0x52
  's': _KeyPosition(5, 3), // 0x53
  't': _KeyPosition(5, 4), // 0x54
  'u': _KeyPosition(5, 5), // 0x55
  'v': _KeyPosition(5, 6), // 0x56
  'w': _KeyPosition(5, 7), // 0x57
  'x': _KeyPosition(5, 8), // 0x58
  'y': _KeyPosition(5, 9), // 0x59
  'z': _KeyPosition(5, 10), // 0x5A
};
