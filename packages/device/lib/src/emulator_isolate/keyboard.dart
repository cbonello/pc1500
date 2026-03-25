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
  /// Set of currently pressed key names (active during ROM scan).
  final Set<String> _pressedKeys = <String>{};

  /// Queue of keys waiting to be injected. When the user types faster than
  /// the frame rate, key presses pile up. The ROM expects single-key presses,
  /// so we inject one queued key per frame to avoid confusing the scan.
  final List<String> _keyQueue = <String>[];

  /// The key currently being held by the queue (if any).
  String? _heldKey;

  /// Remaining frames to hold the currently injected key.
  int _holdFrames = 0;

  /// Minimum frames to hold each injected key (must be seen by ROM scan).
  /// The ROM needs at least 2 frames: one to detect the key, one to
  /// confirm it's held (debounce). Released on the tick after expiry.
  static const int _minHoldFrames = 2;

  /// Maximum queue depth. Prevents unbounded growth from OS auto-repeat.
  static const int _maxQueueSize = 16;

  /// Press a key by name (e.g. 'a', 'enter', 'f1').
  void keyDown(String keyName) {
    _pressedKeys.add(keyName);
    // Queue the key for guaranteed scan time, but skip duplicates of the
    // most recent entry (OS auto-repeat fires many keyDown events).
    if (_keyQueue.length < _maxQueueSize &&
        (_keyQueue.isEmpty || _keyQueue.last != keyName)) {
      _keyQueue.add(keyName);
    }
  }

  /// Enqueue a key for injection via the queue.
  ///
  /// Unlike [keyDown], this does NOT add the key to [_pressedKeys]. The key
  /// will be pressed by [tickKeyQueue] for [_minHoldFrames], then released.
  void enqueue(String keyName) {
    if (_keyQueue.length < _maxQueueSize) {
      _keyQueue.add(keyName);
    }
  }

  /// Release a key by name.
  ///
  /// The key is removed from the immediate pressed set but NOT from the
  /// queue. Queued keystrokes still need to be injected so the ROM sees them.
  void keyUp(String keyName) {
    _pressedKeys.remove(keyName);
  }

  /// Called once per frame AFTER the ROM has scanned the keyboard.
  /// Manages the key queue: decrements the hold counter, releases the
  /// previous key, and immediately injects the next queued key in the
  /// same tick so there is no wasted "gap" frame between keystrokes.
  void tickKeyQueue() {
    if (_holdFrames > 0) {
      _holdFrames--;
      return; // Still holding the current key.
    }
    // Release the previously held key now that its hold time expired.
    if (_heldKey != null) {
      _pressedKeys.remove(_heldKey);
      _heldKey = null;
    }
    // Immediately inject the next queued key (no gap frame).
    if (_keyQueue.isNotEmpty) {
      _heldKey = _keyQueue.removeAt(0);
      _pressedKeys.add(_heldKey!);
      _holdFrames = _minHoldFrames;
    }
  }

  /// Whether there are keys waiting in the queue.
  bool get hasQueuedKeys => _keyQueue.isNotEmpty;

  /// Returns true if the ON key is currently pressed.
  bool get isOnKeyPressed => _pressedKeys.contains('on');

  /// Debug: returns an unmodifiable view of the currently pressed key names.
  Set<String> get debugPressedKeys => Set<String>.unmodifiable(_pressedKeys);

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
      if (pos == null) {
        continue;
      }

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
/// PA0:   ▲        N        Y        SHIFT    H        8        5        2
/// PA1:   TAB      X        W        DEF/F1   S        →        -        .
/// PA2:   0        M        U        F5       J        7        4        1
/// PA3:   ENTER    (        I        F6/↕     K        O        L        )
/// PA4:   RCL      C        E        F2       D        /        *        +
/// PA5:   SPACE    V        R        F3       F        P        ←        =
/// PA6:   SML/BRK  Z        Q        DEF      A        CL       MODE     (ctrl)
/// PA7:   ▼        B        T        F4       G        9        6        3
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
  // SHIFT is handled directly via toggleShift() — not a matrix key.
  // Function/control keys
  'recall': _KeyPosition(4, 7), // PA4, IN7 → RCL (0x19)
  'def': _KeyPosition(1, 4), // PA1, IN4 → DEF
  // SML and BREAK share PA6/IN7 — same physical matrix position.
  // On export models, code 0x02 toggles SMALL mode.
  'small': _KeyPosition(6, 7), // PA6, IN7 → 0x02
  'break': _KeyPosition(6, 7), // PA6, IN7 → 0x02 (same as SML)
  'up-down': _KeyPosition(3, 4), // PA3, IN4 → key code 0x16 (↕ reserve toggle)
  'clear': _KeyPosition(6, 2), // PA6, IN2 → CL (0x18)
  // MODE is a physical slide switch on the real PC-1500, handled
  // by cycleMode() in the emulator — not a keyboard matrix key.

  // Navigation
  'right': _KeyPosition(1, 2), // PA1, IN2 → 0x0F (→)
  'left': _KeyPosition(5, 1), // PA5, IN1 → 0x08 (← / BS)
  'down': _KeyPosition(7, 7), // PA7, IN7 → 0x0A (▼, SHIFT+▼ = π)
  'up': _KeyPosition(0, 7), // PA0, IN7 → 0x0B (▲, SHIFT+▲ = √)
  // Additional function keys
  'tab': _KeyPosition(1, 7), // PA1, IN7 → 0x09 (TAB)
  // F1-F6 (all on IN4 row; SHIFT+Fn produces !, ", #, $, %, &)
  'f1': _KeyPosition(1, 4), // PA1, IN4 → 0x11 (same key as DEF)
  'f2': _KeyPosition(4, 4), // PA4, IN4 → 0x12
  'f3': _KeyPosition(5, 4), // PA5, IN4 → 0x13
  'f4': _KeyPosition(7, 4), // PA7, IN4 → 0x14
  'f5': _KeyPosition(2, 4), // PA2, IN4 → 0x15
  'f6': _KeyPosition(3, 4), // PA3, IN4 → 0x16
};
