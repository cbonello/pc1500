import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        if (snapshot.hasData == false) {
          return Container();
        }

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
                  child: CustomPaint(
                    painter: _Screen(
                      config: config,
                      lcdEvent: snapshot.data,
                    ),
                  ),
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
  const _Screen({
    @required this.config,
    @required this.lcdEvent,
  }) : assert(config != null);

  final LcdModel config;
  final LcdEvent lcdEvent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pxOn = Paint()..color = Color(config.colors.pixelOn);
    final Paint pxOff = Paint()..color = Color(config.colors.pixelOff);

    void _displaySymbol(String label, double left) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: GoogleFonts.openSans(
            textStyle: const TextStyle(
              color: Color(0xFF000000),
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
        ),
        textScaleFactor: 0.8,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      textPainter.paint(canvas, Offset(left, 0.0));
    }

    void _displayPixel(bool isOn, int x, int y) {
      canvas.drawRect(
        Rect.fromLTWH(
          x * (config.pixels.width + config.pixels.gap),
          y * (config.pixels.height + config.pixels.gap) + config.pixels.top,
          config.pixels.width,
          config.pixels.height,
        ),
        isOn ? pxOn : pxOff,
      );
    }

    void _displayBuffer(
      Uint8ClampedList buffer,
      int xStart1,
      int xStart2,
    ) {
      int x1 = xStart1;
      int x2 = xStart2;

      for (int i = 0; i <= buffer.length - 2; i += 2, x1++, x2++) {
        final int low = buffer[i];
        _displayPixel(low & 0x10 == 0x10, x1, 0);
        _displayPixel(low & 0x20 == 0x20, x1, 1);
        _displayPixel(low & 0x40 == 0x40, x1, 2);
        _displayPixel(low & 0x80 == 0x80, x1, 3);

        _displayPixel(low & 0x01 == 0x01, x2, 0);
        _displayPixel(low & 0x02 == 0x02, x2, 1);
        _displayPixel(low & 0x04 == 0x04, x2, 2);
        _displayPixel(low & 0x08 == 0x08, x2, 3);

        final int high = buffer[i + 1];
        _displayPixel(high & 0x10 == 0x10, x1, 4);
        _displayPixel(high & 0x20 == 0x20, x1, 5);
        _displayPixel(high & 0x40 == 0x40, x1, 6);

        _displayPixel(high & 0x01 == 0x01, x2, 4);
        _displayPixel(high & 0x02 == 0x02, x2, 5);
        _displayPixel(high & 0x04 == 0x04, x2, 6);
      }
    }

    _displayBuffer(lcdEvent.displayBuffer1, 78, 0);
    _displayBuffer(lcdEvent.displayBuffer2, 117, 39);

    if (lcdEvent.symbols.busy) {
      _displaySymbol('BUSY', 2);
    }
    if (lcdEvent.symbols.shift) {
      _displaySymbol('SHIFT', 80.0);
    }
    if (lcdEvent.symbols.small) {
      _displaySymbol('SMALL', 175.0);
    }
    if (lcdEvent.symbols.def) {
      _displaySymbol('DEF', 620.0);
    }
    if (lcdEvent.symbols.one) {
      _displaySymbol('I', 672.0);
    }
    if (lcdEvent.symbols.two) {
      _displaySymbol('II', 678.0);
    }
    if (lcdEvent.symbols.three) {
      _displaySymbol('III', 689.0);
    }

    if (lcdEvent.symbols.de) {
      _displaySymbol('DE', 265.0);
    }
    if (lcdEvent.symbols.g) {
      _displaySymbol('G', 283.0);
    }
    if (lcdEvent.symbols.rad) {
      _displaySymbol('RAD', 293.0);
    }
    if (lcdEvent.symbols.run) {
      _displaySymbol('RUN', 390.0);
    }
    if (lcdEvent.symbols.pro) {
      _displaySymbol('PRO', 450.0);
    }
    if (lcdEvent.symbols.reserve) {
      _displaySymbol('RESERVE', 510.0);
    }

    // Battery indicator.
    canvas.drawCircle(
      Offset(155.0 * (config.pixels.width + config.pixels.gap), 8.0),
      3.0,
      pxOn,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
