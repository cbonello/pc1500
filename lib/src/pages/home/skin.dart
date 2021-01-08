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
    final Map<int, _Button> btnsMap = <int, _Button>{};

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event.runtimeType.toString() == 'RawKeyUpEvent') {
          if (btnsMap.containsKey(event.logicalKey.keyId)) {
            // btnsMap[event.logicalKey.keyId].animate();
          }
        }
      },
      child: Stack(
        children: <Widget>[
          widget.lcd,
          Image.asset(widget.skin.image),
          ...widget.skin.keys.keys.map<Widget>(
            (String value) {
              final KeyModel key = widget.skin.keys[value];
              final _Button btn = _Button(
                value: value,
                keyboardKey: key,
                colors: widget.skin.keyColors[key.color],
                fontSize: key.fontSize,
                onPressed: () {},
              );

              if (_keysToMap.containsKey(value)) {
                btnsMap[_keysToMap[value]] = btn;
              }

              return Positioned(left: key.left, top: key.top, child: btn);
            },
          ).toList(),
        ],
      ),
    );
  }

  static final Map<String, int> _keysToMap = <String, int>{
    'f1': LogicalKeyboardKey.f1.keyId,
    'f2': LogicalKeyboardKey.f2.keyId,
    'f3': LogicalKeyboardKey.f3.keyId,
    'f4': LogicalKeyboardKey.f4.keyId,
    'f5': LogicalKeyboardKey.f5.keyId,
    'f6': LogicalKeyboardKey.f6.keyId,
    // 'shift': LogicalKeyboardKey.shift.keyId,
    'q': LogicalKeyboardKey.keyQ.keyId,
    'w': LogicalKeyboardKey.keyW.keyId,
    'e': LogicalKeyboardKey.keyE.keyId,
    'r': LogicalKeyboardKey.keyR.keyId,
    't': LogicalKeyboardKey.keyT.keyId,
    'y': LogicalKeyboardKey.keyY.keyId,
    'u': LogicalKeyboardKey.keyU.keyId,
    'i': LogicalKeyboardKey.keyI.keyId,
    'o': LogicalKeyboardKey.keyO.keyId,
    'p': LogicalKeyboardKey.keyP.keyId,
    '7': LogicalKeyboardKey.digit7.keyId,
    '8': LogicalKeyboardKey.digit8.keyId,
    '9': LogicalKeyboardKey.digit9.keyId,
    '/': LogicalKeyboardKey.slash.keyId,
    'clear': LogicalKeyboardKey.delete.keyId,
    'a': LogicalKeyboardKey.keyA.keyId,
    's': LogicalKeyboardKey.keyS.keyId,
    'd': LogicalKeyboardKey.keyD.keyId,
    'f': LogicalKeyboardKey.keyF.keyId,
    'g': LogicalKeyboardKey.keyG.keyId,
    'h': LogicalKeyboardKey.keyH.keyId,
    'j': LogicalKeyboardKey.keyJ.keyId,
    'k': LogicalKeyboardKey.keyK.keyId,
    'l': LogicalKeyboardKey.keyL.keyId,
    '=': LogicalKeyboardKey.equal.keyId,
    '4': LogicalKeyboardKey.digit4.keyId,
    '5': LogicalKeyboardKey.digit5.keyId,
    '6': LogicalKeyboardKey.digit6.keyId,
    '*': LogicalKeyboardKey.numpadMultiply.keyId,
    'z': LogicalKeyboardKey.keyZ.keyId,
    'x': LogicalKeyboardKey.keyX.keyId,
    'c': LogicalKeyboardKey.keyC.keyId,
    'v': LogicalKeyboardKey.keyV.keyId,
    'b': LogicalKeyboardKey.keyB.keyId,
    'n': LogicalKeyboardKey.keyN.keyId,
    'm': LogicalKeyboardKey.keyM.keyId,
    '(': LogicalKeyboardKey.numpadParenLeft.keyId,
    ')': LogicalKeyboardKey.numpadParenRight.keyId,
    'up': LogicalKeyboardKey.arrowUp.keyId,
    '1': LogicalKeyboardKey.digit1.keyId,
    '2': LogicalKeyboardKey.digit2.keyId,
    '3': LogicalKeyboardKey.digit3.keyId,
    '-': LogicalKeyboardKey.numpadSubtract.keyId,
    ' ': LogicalKeyboardKey.space.keyId,
    'enter': LogicalKeyboardKey.enter.keyId,
    'left': LogicalKeyboardKey.arrowLeft.keyId,
    'right': LogicalKeyboardKey.arrowRight.keyId,
    'down': LogicalKeyboardKey.arrowDown.keyId,
    '0': LogicalKeyboardKey.digit0.keyId,
    '.': LogicalKeyboardKey.period.keyId,
    'ent': LogicalKeyboardKey.numpadEqual.keyId,
    // '+': LogicalKeyboardKey.numpadAdd.keyId,
  };
}

class _Button extends StatefulWidget {
  const _Button({
    Key key,
    @required this.value,
    @required this.keyboardKey,
    @required this.colors,
    @required this.fontSize,
    @required this.onPressed,
  })  : assert(value != null),
        assert(keyboardKey != null),
        assert(colors != null),
        assert(fontSize != null),
        assert(onPressed != null),
        super(key: key);

  final String value;
  final KeyModel keyboardKey;
  final ColorModel colors;
  final double fontSize;
  final VoidCallback onPressed;

  @override
  __ButtonState createState() => __ButtonState();
}

class __ButtonState extends State<_Button> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  double width, height;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    width = widget.keyboardKey.width;
    height = widget.keyboardKey.height;
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void animate() {
    _animationController
      ..forward()
      ..reverse();
  }

  @override
  Widget build(BuildContext context) {
    final Widget value = widget.keyboardKey.label.when<Widget>(
      text: (String value) {
        return Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              color: Color(widget.colors.color),
              fontSize: widget.fontSize,
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
              size: widget.fontSize,
              color: Color(widget.colors.color),
            );
          case 'up':
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                MfgLabs.up_bold,
                size: widget.fontSize,
                color: Color(widget.colors.color),
              ),
            );
          case 'right':
            return Icon(
              ModernPictograms.right_dir,
              size: widget.fontSize,
              color: Color(widget.colors.color),
            );
          case 'down':
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                MfgLabs.down_bold,
                size: widget.fontSize,
                color: Color(widget.colors.color),
              ),
            );
          case 'up-down':
            return Icon(
              FontAwesome.sort,
              size: widget.fontSize,
              color: Color(widget.colors.color),
            );
          default:
            throw Exception('Invalid icon type: $value');
        }
      },
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Color(widget.colors.background),
        border: Border(
          right: BorderSide(
            color: Color(widget.colors.border),
            width: 0.5,
          ),
          bottom: BorderSide(
            color: Color(widget.colors.border),
            width: 0.5,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: FittedBox(child: value),
        ),
      ),
    );
  }
}
