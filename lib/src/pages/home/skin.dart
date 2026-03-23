import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pc1500/src/pages/home/lcd.dart';
import 'package:pc1500/src/repositories/systems/models/models.dart';

// Native pixel dimensions of the skin image.
const double _skinWidth = 1506;
const double _skinHeight = 628;

/// The full PC-1500 skin: LCD display, keyboard buttons, and background image.
///
/// Handles both physical keyboard input (via [KeyboardListener]) and
/// on-screen button presses (via [_KeyButton]).
class Skin extends StatefulWidget {
  const Skin({
    super.key,
    required this.skin,
    required this.lcd,
    required this.device,
  });

  final SkinModel skin;
  final LcdWidget lcd;
  final Device device;

  @override
  State<Skin> createState() => _SkinState();
}

class _SkinState extends State<Skin> {
  late final FocusNode _focusNode;

  /// Tracks which on-screen buttons appear visually pressed.
  final Set<String> _pressedKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyDown(String keyName) {
    // Skip if already pressed (OS auto-repeat sends duplicate KeyDownEvents).
    if (_pressedKeys.contains(keyName)) return;
    widget.device.sendKeyDown(keyName);
    setState(() => _pressedKeys.add(keyName));
  }

  void _onKeyUp(String keyName) {
    widget.device.sendKeyUp(keyName);
    setState(() => _pressedKeys.remove(keyName));
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        // Ignore KeyRepeatEvent — only act on initial press and release.
        if (event is! KeyDownEvent && event is! KeyUpEvent) return;

        final String? keyName = _physicalKeyMap[event.logicalKey];
        if (keyName != null) {
          if (event is KeyDownEvent) {
            _onKeyDown(keyName);
          } else if (event is KeyUpEvent) {
            _onKeyUp(keyName);
          }
        }
      },
      // FittedBox scales from the skin's native pixel space to the
      // available window size. All Positioned coordinates are in the
      // image's native pixel space — no device-pixel-ratio issues.
      child: FittedBox(
        child: SizedBox(
          width: _skinWidth,
          height: _skinHeight,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: widget.skin.lcd.left,
                top: widget.skin.lcd.top,
                child: widget.lcd,
              ),
              Positioned.fill(
                child: Image.asset(widget.skin.image, fit: BoxFit.fill),
              ),
              ...widget.skin.keys.keys.map<Widget>((String value) {
                final KeyModel key = widget.skin.keys[value]!;
                return Positioned(
                  left: key.left,
                  top: key.top,
                  child: _KeyButton(
                    keyboardKey: key,
                    colors: widget.skin.keyColors[key.color]!,
                    pressed: _pressedKeys.contains(value),
                    onTapDown: () => _onKeyDown(value),
                    onTapUp: () => _onKeyUp(value),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Maps physical keyboard keys to emulator key names.
  static final Map<LogicalKeyboardKey, String> _physicalKeyMap =
      <LogicalKeyboardKey, String>{
        LogicalKeyboardKey.f1: 'f1',
        LogicalKeyboardKey.f2: 'f2',
        LogicalKeyboardKey.f3: 'f3',
        LogicalKeyboardKey.f4: 'f4',
        LogicalKeyboardKey.f5: 'f5',
        LogicalKeyboardKey.f6: 'f6',
        LogicalKeyboardKey.keyQ: 'q',
        LogicalKeyboardKey.keyW: 'w',
        LogicalKeyboardKey.keyE: 'e',
        LogicalKeyboardKey.keyR: 'r',
        LogicalKeyboardKey.keyT: 't',
        LogicalKeyboardKey.keyY: 'y',
        LogicalKeyboardKey.keyU: 'u',
        LogicalKeyboardKey.keyI: 'i',
        LogicalKeyboardKey.keyO: 'o',
        LogicalKeyboardKey.keyP: 'p',
        LogicalKeyboardKey.keyA: 'a',
        LogicalKeyboardKey.keyS: 's',
        LogicalKeyboardKey.keyD: 'd',
        LogicalKeyboardKey.keyF: 'f',
        LogicalKeyboardKey.keyG: 'g',
        LogicalKeyboardKey.keyH: 'h',
        LogicalKeyboardKey.keyJ: 'j',
        LogicalKeyboardKey.keyK: 'k',
        LogicalKeyboardKey.keyL: 'l',
        LogicalKeyboardKey.keyZ: 'z',
        LogicalKeyboardKey.keyX: 'x',
        LogicalKeyboardKey.keyC: 'c',
        LogicalKeyboardKey.keyV: 'v',
        LogicalKeyboardKey.keyB: 'b',
        LogicalKeyboardKey.keyN: 'n',
        LogicalKeyboardKey.keyM: 'm',
        LogicalKeyboardKey.digit0: '0',
        LogicalKeyboardKey.digit1: '1',
        LogicalKeyboardKey.digit2: '2',
        LogicalKeyboardKey.digit3: '3',
        LogicalKeyboardKey.digit4: '4',
        LogicalKeyboardKey.digit5: '5',
        LogicalKeyboardKey.digit6: '6',
        LogicalKeyboardKey.digit7: '7',
        LogicalKeyboardKey.digit8: '8',
        LogicalKeyboardKey.digit9: '9',
        LogicalKeyboardKey.numpad0: '0',
        LogicalKeyboardKey.numpad1: '1',
        LogicalKeyboardKey.numpad2: '2',
        LogicalKeyboardKey.numpad3: '3',
        LogicalKeyboardKey.numpad4: '4',
        LogicalKeyboardKey.numpad5: '5',
        LogicalKeyboardKey.numpad6: '6',
        LogicalKeyboardKey.numpad7: '7',
        LogicalKeyboardKey.numpad8: '8',
        LogicalKeyboardKey.numpad9: '9',
        LogicalKeyboardKey.numpadDecimal: '.',
        LogicalKeyboardKey.numpadDivide: '/',
        LogicalKeyboardKey.numpadMultiply: '*',
        LogicalKeyboardKey.numpadSubtract: '-',
        LogicalKeyboardKey.numpadAdd: '+',
        LogicalKeyboardKey.numpadEnter: 'enter',
        LogicalKeyboardKey.space: ' ',
        LogicalKeyboardKey.enter: 'enter',
        LogicalKeyboardKey.period: '.',
        LogicalKeyboardKey.equal: '=',
        LogicalKeyboardKey.slash: '/',
        LogicalKeyboardKey.minus: '-',
        LogicalKeyboardKey.arrowLeft: 'left',
        LogicalKeyboardKey.arrowRight: 'right',
        LogicalKeyboardKey.arrowUp: 'up',
        LogicalKeyboardKey.arrowDown: 'down',
        LogicalKeyboardKey.delete: 'clear',
        LogicalKeyboardKey.backspace: 'clear',
      };
}

/// A single key button on the skin, with press/release visual feedback.
class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.keyboardKey,
    required this.colors,
    required this.pressed,
    required this.onTapDown,
    required this.onTapUp,
  });

  final KeyModel keyboardKey;
  final ColorModel colors;
  final bool pressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = pressed
        ? Color.lerp(Color(colors.background), Colors.white, 0.3)!
        : Color(colors.background);

    final Widget label = keyboardKey.label.when<Widget>(
      text: (String value) => Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
            color: Color(colors.color),
            fontSize: keyboardKey.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      icon: (String value) {
        // ↓ and ↑ use Unicode solid triangles to match the real PC-1500.
        if (value == 'down' || value == 'up') {
          return Text(
            value == 'down' ? '▼' : '▲',
            style: TextStyle(
              fontSize: keyboardKey.fontSize * 0.6,
              color: Color(colors.color),
            ),
          );
        }
        return Icon(
          switch (value) {
            'left' => Icons.arrow_left,
            'right' => Icons.arrow_right,
            'up-down' => Icons.swap_vert,
            _ => Icons.error,
          },
          size: keyboardKey.fontSize,
          color: Color(colors.color),
        );
      },
    );

    return Material(
      color: bgColor,
      child: InkWell(
        onTapDown: (_) => onTapDown(),
        onTapUp: (_) => onTapUp(),
        onTapCancel: onTapUp,
        child: SizedBox(
          height: keyboardKey.height,
          width: keyboardKey.width,
          child: Center(child: label),
        ),
      ),
    );
  }
}
