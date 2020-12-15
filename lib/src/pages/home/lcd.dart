import 'dart:ui';

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
                left: config.margin.left,
                top: config.margin.top,
                child: SizedBox(
                  width:
                      config.width - config.margin.left - config.margin.right,
                  height:
                      config.height - config.margin.top - config.margin.bottom,
                  child: CustomPaint(painter: _Screen(config: config)),
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
  const _Screen({@required this.config}) : assert(config != null);

  final LcdModel config;

  @override
  void paint(Canvas canvas, Size size) {
    void _displaySymbol(String label, double left) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          ),
        ),
        textScaleFactor: 0.8,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      textPainter.paint(canvas, Offset(left, 0.0));
    }

    _displaySymbol('BUSY', 2);
    _displaySymbol('SHIFT', 80.0);
    _displaySymbol('SMALL', 175.0);
    _displaySymbol('DEF', 620.0);
    _displaySymbol('I', 672.0);
    _displaySymbol('II', 678.0);
    _displaySymbol('III', 689.0);

    _displaySymbol('DE', 265.0);
    _displaySymbol('G', 283.0);
    _displaySymbol('RAD', 293.0);
    _displaySymbol('RUN', 390.0);
    _displaySymbol('PRO', 450.0);
    _displaySymbol('RESERVE', 510.0);

    final Paint p0 = Paint()..color = const Color(0xFF666052);
    for (int x = 0; x < 156; x++) {
      for (int y = 0; y < 7; y++) {
        canvas.drawRect(
          Rect.fromLTWH(
            x * (config.pixels.width + config.pixels.gap),
            y * (config.pixels.height + config.pixels.gap) + 26.0,
            config.pixels.width,
            config.pixels.height,
          ),
          p0,
        );
      }
    }

    final Paint p1 = Paint()..color = const Color(0xFF2C2721);
    for (int i = 0; i < 7; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          i * (config.pixels.width + config.pixels.gap),
          i * (config.pixels.height + config.pixels.gap) + 26.0,
          config.pixels.width,
          config.pixels.height,
        ),
        p1,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          (i + 1) * (config.pixels.width + config.pixels.gap),
          i * (config.pixels.height + config.pixels.gap) + 26.0,
          config.pixels.width,
          config.pixels.height,
        ),
        p1,
      );
    }

    canvas.drawCircle(
      Offset(155.0 * (config.pixels.width + config.pixels.gap), 8.0),
      3.0,
      p1,
    );

    //   canvas.drawRect(const Rect.fromLTWH(0.0, 21.0 + 0.0, 6.0, 6.0), p1);
    // canvas.drawRect(const Rect.fromLTWH(0.0, 21.0 + 7.0, 6.0, 6.0), p1);
    // canvas.drawRect(const Rect.fromLTWH(0.0, 21.0 + 14.0, 6.0, 6.0), p1);
    // canvas.drawRect(const Rect.fromLTWH(0.0, 21.0 + 21.0, 6.0, 6.0), p1);
    // canvas.drawRect(const Rect.fromLTWH(0.0, 21.0 + 28.0, 6.0, 6.0), p1);
    // canvas.drawRect(const Rect.fromLTWH(0.0, 21.0 + 35.0, 6.0, 6.0), p1);
    // canvas.drawRect(const Rect.fromLTWH(0.0, 21.0 + 42.0, 6.0, 6.0), p1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
