/// PC-1500 keyboard matrix emulator.
///
/// The keyboard matrix has:
/// - 6 strobe columns: PC-1500 I/O PA0-PA5 (active low via DDA/OPA)
/// - 16 input rows split across two sets:
///   - Rows 0-7: CPU IN0-IN7 pins (read via ITA instruction)
///   - Rows 8-F: CE-153 PA0-PA7 (read via CE-153 port A register)
///
/// The key code chart (p.109 Technical Reference Manual) encodes each key as:
///   high nibble (0-5) = column (PA0-PA5 strobe line)
///   low nibble (0-F) = row
///     0-7: IN0-IN7 input
///     8-F: CE-153 PA0-PA7 input (row 8 = PA0, row F = PA7)
///
/// The ON key is NOT in the keyboard matrix. It connects to PB7 of the
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

  /// Debug: returns the set of currently pressed key names.
  Set<String> get debugPressedKeys => _pressedKeys;

  /// Returns the CPU IN0-IN7 response for keyboard rows 0-7.
  ///
  /// Called when the CPU executes ITA. The strobe state comes from
  /// PC-1500 I/O DDA and OPA registers. A PA pin is actively strobing
  /// when DDA bit = 1 and OPA bit = 0.
  ///
  /// Returns IN0-IN7 (active low: 0 = key pressed).
  int scanIN(int dda, int opa) {
    final int activeStrobes = dda & ~opa;
    int result = 0xFF;

    for (final String key in _pressedKeys) {
      final _KeyPosition? pos = _keyMap[key];
      if (pos == null || pos.row >= 8) continue;

      if ((activeStrobes & (1 << pos.column)) != 0) {
        result &= ~(1 << pos.row);
      }
    }

    return result;
  }

  /// Returns the CE-153 PA0-PA7 response for keyboard rows 8-F.
  ///
  /// Called when the CPU reads CE-153 port A. The strobe state comes from
  /// PC-1500 I/O DDA and OPA registers.
  ///
  /// Returns PA0-PA7 (active low: 0 = key pressed).
  int scanCE153(int dda, int opa) {
    final int activeStrobes = dda & ~opa;
    int result = 0xFF;

    for (final String key in _pressedKeys) {
      final _KeyPosition? pos = _keyMap[key];
      if (pos == null || pos.row < 8) continue;

      if ((activeStrobes & (1 << pos.column)) != 0) {
        result &= ~(1 << (pos.row - 8));
      }
    }

    return result;
  }
}

class _KeyPosition {
  const _KeyPosition(this.column, this.row);
  final int column; // Key code high nibble: PA strobe line (0-5).
  final int row; // Key code low nibble: 0-7 = IN bit, 8-15 = CE-153 PA bit.
}

/// Key matrix mapping from skin key names to key code chart positions.
///
/// From the key code chart on p.109 of the Technical Reference Manual.
/// Key code = (column << 4) | row, where column is the high nibble
/// and row is the low nibble.
const Map<String, _KeyPosition> _keyMap = <String, _KeyPosition>{
  // Column 0 (PA0 strobe) — key codes 0x00-0x0F
  'shift': _KeyPosition(0, 1), // 0x01
  'small': _KeyPosition(0, 2), // 0x02
  'up-down': _KeyPosition(0, 4), // 0x04
  'recall': _KeyPosition(0, 5), // 0x05
  'left': _KeyPosition(0, 8), // 0x08 — ◄
  'up': _KeyPosition(0, 10), // 0x0A — ↑
  'down': _KeyPosition(0, 11), // 0x0B — ↓
  'right': _KeyPosition(0, 12), // 0x0C — ►
  'enter': _KeyPosition(0, 13), // 0x0D
  'off': _KeyPosition(0, 15), // 0x0F

  // Column 1 (PA1 strobe) — key codes 0x10-0x1F
  'f1': _KeyPosition(1, 1), // 0x11
  'f2': _KeyPosition(1, 2), // 0x12
  'f3': _KeyPosition(1, 3), // 0x13
  'f4': _KeyPosition(1, 4), // 0x14
  'f5': _KeyPosition(1, 5), // 0x15
  'f6': _KeyPosition(1, 6), // 0x16
  'clear': _KeyPosition(1, 8), // 0x18 — CL
  '*': _KeyPosition(1, 10), // 0x1A
  'def': _KeyPosition(1, 11), // 0x1B
  'mode': _KeyPosition(1, 15), // 0x1F

  // Column 2 (PA2 strobe) — key codes 0x20-0x2F
  ' ': _KeyPosition(2, 0), // 0x20 — SPACE
  '(': _KeyPosition(2, 8), // 0x28
  ')': _KeyPosition(2, 9), // 0x29
  '+': _KeyPosition(2, 11), // 0x2B
  '-': _KeyPosition(2, 13), // 0x2D
  '.': _KeyPosition(2, 14), // 0x2E
  '/': _KeyPosition(2, 15), // 0x2F

  // Column 3 (PA3 strobe) — key codes 0x30-0x3F
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

  // Column 4 (PA4 strobe) — key codes 0x40-0x4F
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

  // Column 5 (PA5 strobe) — key codes 0x50-0x5F
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
