import 'package:flutter/material.dart';

import '../../repositories/systems/models/models.dart';

class LCD extends StatefulWidget {
  const LCD({
    Key key,
    @required this.config,
  }) : super(key: key);

  final LCDModel config;

  @override
  _LCDState createState() => _LCDState();
}

class _LCDState extends State<LCD> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.config.left,
      top: widget.config.top,
      child: Container(
        height: widget.config.height,
        width: widget.config.width,
        color: Color(widget.config.background),
      ),
    );
  }
}
