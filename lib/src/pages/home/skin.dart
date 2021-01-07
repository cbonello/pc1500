import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../repositories/systems/models/models.dart';
import 'lcd.dart';

class Skin extends StatefulWidget {
  const Skin({Key key, @required this.skin, @required this.lcd})
      : assert(skin != null),
        assert(lcd != null),
        super(key: key);

  final SkinModel skin;
  final LcdWidget lcd;

  @override
  _SkinState createState() => _SkinState();
}

class _SkinState extends State<Skin> {
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<LogicalKeyboardKey, Widget> btnsMap =
        <LogicalKeyboardKey, Widget>{};

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) async {
        if (event.runtimeType.toString() == 'RawKeyUpEvent') {
          print(event.logicalKey);
        }
      },
      child: Stack(
        children: <Widget>[
          widget.lcd,
          Image.asset(widget.skin.image),
          ...widget.skin.keys.values.map<Widget>(
            (KeyModel key) {
              return Positioned(
                left: key.left,
                top: key.top,
                child: Container(
                  height: key.height,
                  width: key.width,
                  decoration: BoxDecoration(
                    color: Color(widget.skin.keyColors[key.color].background),
                    border: Border(
                      right: BorderSide(
                        color: Color(widget.skin.keyColors[key.color].border),
                        width: 0.5,
                      ),
                      bottom: BorderSide(
                        color: Color(widget.skin.keyColors[key.color].border),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Builder(
                    builder: (BuildContext context) {
                      final Widget btn = _Button(
                        label: key.label,
                        color: Color(widget.skin.keyColors[key.color].color),
                        fontSize: key.fontSize,
                        onPressed: () {},
                      );

                      if (_keysToMap.containsKey(key.label)) {
                        btnsMap[_keysToMap[key.label]] = btn;
                      }

                      return btn;
                    },
                  ),
                ),
              );
            },
          ).toList(),
        ],
      ),
    );
  }

  static const Map<String, LogicalKeyboardKey> _keysToMap =
      <String, LogicalKeyboardKey>{
    'f1': LogicalKeyboardKey.f1,
    'f2': LogicalKeyboardKey.f2,
    'f3': LogicalKeyboardKey.f3,
    'f4': LogicalKeyboardKey.f4,
    'f5': LogicalKeyboardKey.f5,
    'f6': LogicalKeyboardKey.f6,
    'shift': LogicalKeyboardKey.shift,
    'q': LogicalKeyboardKey.keyQ,
    'w': LogicalKeyboardKey.keyW,
    'e': LogicalKeyboardKey.keyE,
    'r': LogicalKeyboardKey.keyR,
    't': LogicalKeyboardKey.keyT,
    'y': LogicalKeyboardKey.keyY,
    'u': LogicalKeyboardKey.keyU,
    'i': LogicalKeyboardKey.keyI,
    'o': LogicalKeyboardKey.keyO,
    'p': LogicalKeyboardKey.keyP,
    '7': LogicalKeyboardKey.digit7,
    '8': LogicalKeyboardKey.digit8,
    '9': LogicalKeyboardKey.digit9,
    '/': LogicalKeyboardKey.slash,
    'clear': LogicalKeyboardKey.delete,
    'a': LogicalKeyboardKey.keyA,
    's': LogicalKeyboardKey.keyS,
    'd': LogicalKeyboardKey.keyD,
    'f': LogicalKeyboardKey.keyF,
    'g': LogicalKeyboardKey.keyG,
    'h': LogicalKeyboardKey.keyH,
    'j': LogicalKeyboardKey.keyJ,
    'k': LogicalKeyboardKey.keyK,
    'l': LogicalKeyboardKey.keyL,
    '=': LogicalKeyboardKey.equal,
    '4': LogicalKeyboardKey.digit4,
    '5': LogicalKeyboardKey.digit5,
    '6': LogicalKeyboardKey.digit6,
    '*': LogicalKeyboardKey.numpadMultiply,
    'z': LogicalKeyboardKey.keyZ,
    'x': LogicalKeyboardKey.keyX,
    'c': LogicalKeyboardKey.keyC,
    'v': LogicalKeyboardKey.keyV,
    'b': LogicalKeyboardKey.keyB,
    'n': LogicalKeyboardKey.keyN,
    'm': LogicalKeyboardKey.keyM,
    '(': LogicalKeyboardKey.numpadParenLeft,
    ')': LogicalKeyboardKey.numpadParenRight,
    'up': LogicalKeyboardKey.arrowUp,
    '1': LogicalKeyboardKey.digit1,
    '2': LogicalKeyboardKey.digit2,
    '3': LogicalKeyboardKey.digit3,
    '-': LogicalKeyboardKey.numpadSubtract,
    ' ': LogicalKeyboardKey.space,
    'enter': LogicalKeyboardKey.enter,
    'left': LogicalKeyboardKey.arrowLeft,
    'right': LogicalKeyboardKey.arrowRight,
    'down': LogicalKeyboardKey.arrowDown,
    '0': LogicalKeyboardKey.digit0,
    '.': LogicalKeyboardKey.period,
    'ent': LogicalKeyboardKey.numpadEqual,
    '+': LogicalKeyboardKey.numpadAdd,
  };
}

class _Button extends StatelessWidget {
  const _Button({
    Key key,
    @required this.label,
    @required this.color,
    @required this.fontSize,
    @required this.onPressed,
  })  : assert(label != null),
        assert(color != null),
        assert(fontSize != null),
        assert(onPressed != null),
        super(key: key);

  final KeyLabelModel label;
  final Color color;
  final double fontSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Widget value = label.when<Widget>(
      text: (String value) {
        return Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      icon: (String value) {
        switch (value) {
          case 'left':
            return Icon(
              ModernPictograms.left_dir,
              size: fontSize,
              color: color,
            );
          case 'up':
            return Icon(MfgLabs.up_bold, size: fontSize, color: color);
          case 'right':
            return Icon(
              ModernPictograms.right_dir,
              size: fontSize,
              color: color,
            );
          case 'down':
            return Icon(MfgLabs.down_bold, size: fontSize, color: color);
          case 'up-down':
            return Icon(FontAwesome.sort, size: fontSize, color: color);
          default:
            throw Exception('Invalid icon type: $value');
        }
      },
    );

    return TextButton(
      onPressed: () {},
      child: FittedBox(child: value),
    );
  }
}
