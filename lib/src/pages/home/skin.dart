import 'package:flutter/material.dart';

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
          color: Color(widget.skin.colors[key.value.color].background),
          child: Center(
            child: Text(
              key.key,
              style: TextStyle(
                color: Color(widget.skin.colors[key.value.color].color),
                fontWeight: FontWeight.bold,
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
