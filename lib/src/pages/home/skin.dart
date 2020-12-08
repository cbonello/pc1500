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
          child: FittedBox(
            child: Text(
              key.value.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  color: Color(widget.skin.colors[key.value.color].color),
                  fontSize: key.value.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
