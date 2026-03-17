/// PC-1500 keyboard matrix emulator.
///
/// The keyboard is an 8×8 matrix scanned by the ROM:
/// - 8 strobe columns: PC-1500 I/O PA0-PA7 (active low via DDA/OPA)
/// - 8 input rows: CPU IN0-IN7 pins (read via ITA instruction)
///
/// The ROM's key scan routine (KEYSCANl at E42C) scans PA0-PA7 one at a time,
/// reads ITA, and uses the result as an index into a lookup table at FE80.
/// Table index = column * 8 + (7 - IN_bit), scanning IN7 first.
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

  /// Returns the CPU IN0-IN7 response for the keyboard matrix.
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
      if (pos == null) continue;

      if ((activeStrobes & (1 << pos.column)) != 0) {
        result &= ~(1 << pos.row);
      }
    }

    return result;
  }
}

class _KeyPosition {
  const _KeyPosition(this.column, this.row);
  final int column; // PA strobe line (0-7).
  final int row; // IN bit (0-7).
}

/// Key matrix mapping from skin key names to physical PA/IN positions.
///
/// Derived from the ROM's key lookup table at FE80-FEBF.
/// The ROM scans PA0-PA7 columns and reads IN0-IN7 rows.
/// Table index = column * 8 + (7 - IN_bit).
///
/// ROM table layout (each row = one PA column):
///        [+0]IN7  [+1]IN6  [+2]IN5  [+3]IN4  [+4]IN3  [+5]IN2  [+6]IN1  [+7]IN0
/// PA0:   CLS      N        Y        (ON)     H        8        5        2
/// PA1:   TAB      X        W        DEF      S        →        -        .
/// PA2:   0        M        U        SML      J        7        4        1
/// PA3:   ENTER    (        I        SHIFT    K        O        L        )
/// PA4:   RCL      C        E        (mode?)  D        /        *        +
/// PA5:   SPACE    V        R        (mode?)  F        P        ←        =
/// PA6:   BRK      Z        Q        (mode?)  A        CL       MODE     (ctrl)
/// PA7:   LF       B        T        (mode?)  G        9        6        3
const Map<String, _KeyPosition> _keyMap = <String, _KeyPosition>{
  // Digits
  '0': _KeyPosition(2, 7), // PA2, IN7
  '1': _KeyPosition(2, 0), // PA2, IN0
  '2': _KeyPosition(0, 0), // PA0, IN0
  '3': _KeyPosition(7, 0), // PA7, IN0
  '4': _KeyPosition(2, 1), // PA2, IN1
  '5': _KeyPosition(0, 1), // PA0, IN1
  '6': _KeyPosition(7, 1), // PA7, IN1
  '7': _KeyPosition(2, 2), // PA2, IN2
  '8': _KeyPosition(0, 2), // PA0, IN2
  '9': _KeyPosition(7, 2), // PA7, IN2

  // Letters
  'a': _KeyPosition(6, 3), // PA6, IN3
  'b': _KeyPosition(7, 6), // PA7, IN6
  'c': _KeyPosition(4, 6), // PA4, IN6
  'd': _KeyPosition(4, 3), // PA4, IN3
  'e': _KeyPosition(4, 5), // PA4, IN5
  'f': _KeyPosition(5, 3), // PA5, IN3
  'g': _KeyPosition(7, 3), // PA7, IN3
  'h': _KeyPosition(0, 3), // PA0, IN3
  'i': _KeyPosition(3, 5), // PA3, IN5
  'j': _KeyPosition(2, 3), // PA2, IN3
  'k': _KeyPosition(3, 3), // PA3, IN3
  'l': _KeyPosition(3, 1), // PA3, IN1
  'm': _KeyPosition(2, 6), // PA2, IN6
  'n': _KeyPosition(0, 6), // PA0, IN6
  'o': _KeyPosition(3, 2), // PA3, IN2
  'p': _KeyPosition(5, 2), // PA5, IN2
  'q': _KeyPosition(6, 5), // PA6, IN5
  'r': _KeyPosition(5, 5), // PA5, IN5
  's': _KeyPosition(1, 3), // PA1, IN3
  't': _KeyPosition(7, 5), // PA7, IN5
  'u': _KeyPosition(2, 5), // PA2, IN5
  'v': _KeyPosition(5, 6), // PA5, IN6
  'w': _KeyPosition(1, 5), // PA1, IN5
  'x': _KeyPosition(1, 6), // PA1, IN6
  'y': _KeyPosition(0, 5), // PA0, IN5
  'z': _KeyPosition(6, 6), // PA6, IN6

  // Special keys
  'enter': _KeyPosition(3, 7), // PA3, IN7 → 0x0D
  ' ': _KeyPosition(5, 7), // PA5, IN7 → SPACE
  '(': _KeyPosition(3, 6), // PA3, IN6
  ')': _KeyPosition(3, 0), // PA3, IN0
  '+': _KeyPosition(4, 0), // PA4, IN0
  '-': _KeyPosition(1, 1), // PA1, IN1
  '*': _KeyPosition(4, 1), // PA4, IN1
  '/': _KeyPosition(4, 2), // PA4, IN2
  '.': _KeyPosition(1, 0), // PA1, IN0
  '=': _KeyPosition(5, 0), // PA5, IN0

  // Function/control keys
  'shift': _KeyPosition(0, 4), // PA0, IN4 → 0x01 (SHIFT toggle)
  'recall': _KeyPosition(4, 7), // PA4, IN7 → RCL
  'def': _KeyPosition(1, 4), // PA1, IN4 → DEF
  'small': _KeyPosition(6, 7), // PA6, IN7 → 0x02 (MODE toggles SMALL on export)
  'up-down': _KeyPosition(3, 4), // PA3, IN4 → 0x16
  'clear': _KeyPosition(6, 2), // PA6, IN2 → CL (0x18)
  // MODE (RUN/PRO toggle) may use a hardware switch rather than matrix key.
  // TODO: investigate MODE mechanism on export model.

  // Navigation
  'right': _KeyPosition(1, 2), // PA1, IN2 → 0x0F (→)
  'left': _KeyPosition(5, 1), // PA5, IN1 → 0x08 (← / BS)
};
