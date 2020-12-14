import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../repositories/systems/models/models.dart';
import 'lcd.dart';

class Skin extends StatelessWidget {
  const Skin({Key key, @required this.skin, @required this.lcd})
      : assert(skin != null),
        assert(lcd != null),
        super(key: key);

  final SkinModel skin;
  final LcdWidget lcd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        lcd,
        Image.asset(skin.image),
        ...skin.keys.values.map<Widget>(
          (KeyModel key) {
            return Positioned(
              left: key.left,
              top: key.top,
              child: Container(
                height: key.height,
                width: key.width,
                decoration: BoxDecoration(
                  color: Color(skin.keyColors[key.color].background),
                  border: Border(
                    right: BorderSide(
                      color: Color(skin.keyColors[key.color].border),
                      width: 0.5,
                    ),
                    bottom: BorderSide(
                      color: Color(skin.keyColors[key.color].border),
                      width: 0.5,
                    ),
                  ),
                ),
                child: _Button(
                  label: key.label,
                  color: Color(skin.keyColors[key.color].color),
                  fontSize: key.fontSize,
                  onPressed: () {},
                ),
              ),
            );
          },
        ).toList(),
      ],
    );
  }
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
