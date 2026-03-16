/// PC-1500 keyboard matrix emulator.
///
/// The keyboard uses the CE-153 LH5811 I/O port controller at ME1 0x8000.
/// Key scanning works by:
/// 1. CPU writes to PB2-PB7 and PC0-PC7 (strobe lines, active low)
/// 2. CPU reads PA0-PA7 and PB0-PB1 (input lines)
///
/// From the Technical Reference Manual (p.109, p.113):
/// - The key code chart uses a high nibble (column 0-5) and low nibble (row 0-F)
/// - The ON key is connected to PB7 of the PC-1500 I/O PC (#F00BH)
///
/// For simplicity, we map key names (matching the skin JSON) to (column, row)
/// positions in the matrix, and compute the PA/PB input state based on which
/// strobe lines are active.
class Keyboard {
  /// Set of currently pressed key names.
  final Set<String> _pressedKeys = <String>{};

  /// Press a key by name (e.g. 'a', 'enter', 'f1').
  void keyDown(String keyName) => _pressedKeys.add(keyName);

  /// Release a key by name.
  void keyUp(String keyName) => _pressedKeys.remove(keyName);

  /// Returns true if the ON key is currently pressed.
  bool get isOnKeyPressed => _pressedKeys.contains('on');

  /// Scans the keyboard matrix for the given strobe state.
  ///
  /// The CE-153 uses PB2-PB7 and PC0-PC7 as strobe outputs (active low).
  /// This method returns the PA0-PA7 and PB0-PB1 input state (active low)
  /// based on which keys are pressed and which strobe lines are active.
  ///
  /// [strobePB] is the PB output (bits 2-7 are strobe lines).
  /// [strobePC] is the PC output (bits 0-7 are strobe lines).
  /// Returns the PA input byte (bits 0-7).
  int scanPortA(int strobePB, int strobePC) {
    int result = 0xFF; // All high = no keys pressed.

    for (final String key in _pressedKeys) {
      final _KeyPosition? pos = _keyMap[key];
      if (pos == null) continue;

      // Check if this key's strobe line is active (low).
      final bool strobeActive = _isStrobeActive(pos.column, strobePB, strobePC);
      if (strobeActive && pos.row < 8) {
        result &= ~(1 << pos.row); // Drive the row line low.
      }
    }

    return result;
  }

  /// Returns the PB input byte (only bits 0-1 are key inputs).
  int scanPortB(int strobePB, int strobePC) {
    int result = 0xFF;

    for (final String key in _pressedKeys) {
      final _KeyPosition? pos = _keyMap[key];
      if (pos == null) continue;

      final bool strobeActive = _isStrobeActive(pos.column, strobePB, strobePC);
      if (strobeActive && pos.row >= 8) {
        result &= ~(1 << (pos.row - 8)); // PB0 or PB1.
      }
    }

    return result;
  }

  /// Checks if a given column's strobe line is active (low).
  /// Columns 0-5 map to PB2-PB7, columns 6-13 map to PC0-PC7.
  bool _isStrobeActive(int column, int strobePB, int strobePC) {
    if (column < 6) {
      // PB2-PB7 (column 0 = PB2, column 5 = PB7).
      return (strobePB & (1 << (column + 2))) == 0;
    } else {
      // PC0-PC7 (column 6 = PC0, column 13 = PC7).
      return (strobePC & (1 << (column - 6))) == 0;
    }
  }
}

class _KeyPosition {
  const _KeyPosition(this.column, this.row);
  final int column; // Strobe column (0-13).
  final int row;    // Input row (0-7 = PA0-PA7, 8-9 = PB0-PB1).
}

/// Key matrix mapping from skin key names to (column, row) positions.
///
/// Derived from the key code chart on p.109 of the Technical Reference Manual.
/// The key code high nibble maps to column, low nibble maps to row.
///
/// Key code format: high nibble = column (0-5), low nibble = row (0-F).
/// Row 0-7 → PA0-PA7, Row 8-9 → PB0-PB1.
/// Row A-F → extended rows via PC strobes.
const Map<String, _KeyPosition> _keyMap = <String, _KeyPosition>{
  // Column 0 (high nibble 0): keys with codes 0x00-0x0F
  'off': _KeyPosition(0, 0),       // 0x00
  'shift': _KeyPosition(0, 1),     // 0x01 - SHIFT
  'small': _KeyPosition(0, 2),     // 0x02 - SML
  'mode': _KeyPosition(0, 3),      // 0x03
  'up-down': _KeyPosition(0, 4),   // 0x04
  'recall': _KeyPosition(0, 5),    // 0x05
  'def': _KeyPosition(0, 11),      // 0x0B - DEF
  'enter': _KeyPosition(0, 13),    // 0x0D - ENTER
  'on': _KeyPosition(0, 15),       // 0x0F - OFF (mapped to ON key)

  // Column 1 (high nibble 1): keys with codes 0x10-0x1F
  'f1': _KeyPosition(1, 1),        // 0x11
  'f2': _KeyPosition(1, 2),        // 0x12
  'f3': _KeyPosition(1, 3),        // 0x13
  'f4': _KeyPosition(1, 4),        // 0x14
  'f5': _KeyPosition(1, 5),        // 0x15
  'f6': _KeyPosition(1, 6),        // 0x16
  'left': _KeyPosition(1, 8),      // 0x18
  'up': _KeyPosition(1, 9),        // 0x19
  '*': _KeyPosition(1, 10),        // 0x1A
  'clear': _KeyPosition(1, 8),     // 0x18 - CL
  'right': _KeyPosition(1, 12),    // 0x1C
  '/': _KeyPosition(1, 15),        // 0x1F

  // Column 2 (high nibble 2): keys with codes 0x20-0x2F
  '0': _KeyPosition(2, 0),         // 0x20
  '1': _KeyPosition(2, 2),         // 0x22
  '2': _KeyPosition(2, 3),         // 0x23
  '3': _KeyPosition(2, 4),         // 0x24
  '4': _KeyPosition(2, 5),         // 0x25
  '5': _KeyPosition(2, 6),         // 0x26
  '6': _KeyPosition(2, 7),         // 0x27
  '7': _KeyPosition(2, 8),         // 0x28 - mapped via PB0
  '8': _KeyPosition(2, 9),         // 0x29 - mapped via PB1
  '(': _KeyPosition(2, 8),         // 0x28
  ')': _KeyPosition(2, 9),         // 0x29
  '.': _KeyPosition(2, 12),        // 0x2C
  '-': _KeyPosition(2, 13),        // 0x2D
  '=': _KeyPosition(2, 14),        // 0x2E
  '+': _KeyPosition(2, 15),        // 0x2F (via +)

  // Column 3 (high nibble 3)
  '9': _KeyPosition(3, 1),         // 0x31
  'ent': _KeyPosition(3, 14),      // 0x3E

  // Column 4 (high nibble 4): A-N
  'a': _KeyPosition(4, 1),         // 0x41
  'b': _KeyPosition(4, 2),         // 0x42
  'c': _KeyPosition(4, 3),         // 0x43
  'd': _KeyPosition(4, 4),         // 0x44
  'e': _KeyPosition(4, 5),         // 0x45
  'f': _KeyPosition(4, 6),         // 0x46
  'g': _KeyPosition(4, 7),         // 0x47
  'h': _KeyPosition(4, 8),         // 0x48
  'i': _KeyPosition(4, 9),         // 0x49 (mapped via PB1)
  'j': _KeyPosition(4, 10),        // 0x4A
  'k': _KeyPosition(4, 11),        // 0x4B
  'l': _KeyPosition(4, 12),        // 0x4C
  'm': _KeyPosition(4, 13),        // 0x4D
  'n': _KeyPosition(4, 14),        // 0x4E

  // Column 5 (high nibble 5): O-Z, space
  'o': _KeyPosition(5, 0),         // 0x50 (mapped to 'P' position in chart)
  'p': _KeyPosition(5, 0),         // 0x50
  'q': _KeyPosition(5, 1),         // 0x51
  'r': _KeyPosition(5, 2),         // 0x52
  's': _KeyPosition(5, 3),         // 0x53
  't': _KeyPosition(5, 4),         // 0x54
  'u': _KeyPosition(5, 5),         // 0x55
  'v': _KeyPosition(5, 6),         // 0x56
  'w': _KeyPosition(5, 7),         // 0x57
  'x': _KeyPosition(5, 8),         // 0x58
  'y': _KeyPosition(5, 9),         // 0x59
  'z': _KeyPosition(5, 10),        // 0x5A
  ' ': _KeyPosition(5, 0),         // Space
  'down': _KeyPosition(5, 11),     // 0x5B
};
