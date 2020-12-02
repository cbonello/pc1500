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
        // TODO: use doubles in model.
        left: key.value.left.toDouble(),
        top: key.value.top.toDouble(),
        child: Container(
          height: key.value.height.toDouble(),
          width: key.value.width.toDouble(),
          // TODO: convert colors in model.
          color: Color(
            int.tryParse(widget.skin.colors[key.value.color].background,
                radix: 16),
          ),
          child: Center(
            child: Text(
              key.key,
              style: TextStyle(
                color: Color(
                  int.tryParse(widget.skin.colors[key.value.color].color,
                      radix: 16),
                ),
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
