import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../repositories/systems/models/models.dart';
import 'lcd.dart';

class Skin extends StatefulWidget {
  const Skin({Key key, @required this.skin}) : super(key: key);

  final SkinModel skin;

  @override
  _SkinState createState() => _SkinState();
}

class _SkinState extends State<Skin> {
  final Map<String, Widget> keys = <String, Widget>{};

  @override
  void initState() {
    super.initState();

    for (final MapEntry<String, KeyModel> key in widget.skin.keys.entries) {
      keys[key.key] = Positioned(
        left: key.value.left,
        top: key.value.top,
        child: Container(
          height: key.value.height,
          width: key.value.width,
          decoration: BoxDecoration(
            color: Color(widget.skin.colors[key.value.color].background),
            border: Border(
              right: BorderSide(
                color: Color(widget.skin.colors[key.value.color].border),
                width: 0.5,
              ),
              bottom: BorderSide(
                color: Color(widget.skin.colors[key.value.color].border),
                width: 0.5,
              ),
            ),
          ),
          child: _Button(
            label: key.value.label,
            color: Color(widget.skin.colors[key.value.color].color),
            fontSize: key.value.fontSize,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset('assets/systems/pc2.png'),
        ...keys.values,
        LCD(config: widget.skin.lcd),
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
