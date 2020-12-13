import 'package:flutter/material.dart';
import 'package:lcd/lcd.dart';

import '../../repositories/systems/models/models.dart';

class LcdWidget extends StatelessWidget {
  const LcdWidget({
    Key key,
    @required this.config,
    @required this.lcdEvents,
  })  : assert(config != null),
        assert(lcdEvents != null),
        super(key: key);

  final LcdModel config;
  final Stream<LcdEvent> lcdEvents;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LcdEvent>(
      stream: lcdEvents,
      builder: (BuildContext context, AsyncSnapshot<LcdEvent> snapshot) {
        return Positioned(
          left: config.left,
          top: config.top,
          child: Stack(
            children: <Widget>[
              Container(
                height: config.height,
                width: config.width,
                color: Color(config.colors.background),
              ),
              Positioned(
                left: config.offsets.horizontal,
                top: config.offsets.vertical,
                child: SizedBox(
                  width: config.width - (config.offsets.horizontal * 2),
                  height: config.height - (config.offsets.vertical * 2),
                  child: CustomPaint(painter: _Screen()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Screen extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = const Color(0xFF666052);
    final Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
