import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lcd/lcd.dart';

import 'package:pc1500/src/repositories/systems/models/models.dart';

class LcdWidget extends StatelessWidget {
  const LcdWidget({
    super.key,
    required this.config,
    required this.eventsStream,
  });

  final LcdModel config;
  final Stream<LcdEvent> eventsStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LcdEvent>(
      stream: eventsStream,
      builder: (BuildContext context, AsyncSnapshot<LcdEvent> snapshot) {
        if (snapshot.hasData == false) {
          return SizedBox(
            height: config.height,
            width: config.width,
            child: ColoredBox(color: Color(config.colors.background)),
          );
        }

        return SizedBox(
          height: config.height,
          width: config.width,
          child: Stack(
            children: <Widget>[
              ColoredBox(
                color: Color(config.colors.background),
                child: const SizedBox.expand(),
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
                    painter: _Screen(config: config, lcdEvent: snapshot.data!),
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
  const _Screen({required this.config, required this.lcdEvent});

  final LcdModel config;
  final LcdEvent lcdEvent;

  @override
  void paint(Canvas canvas, Size size) {
    // When the display is off (DISP flip-flop cleared by RDP instruction),
    // the LCD shows a blank screen — no pixels, no symbols.
    if (!lcdEvent.displayOn) return;

    // See PC-1500 Technical Reference Manual, page 98.
    final Paint pxOn = Paint()..color = Color(config.colors.pixelOn);
    final Paint pxOff = Paint()..color = Color(config.colors.pixelOff);
    final Color symOn = Color(config.colors.symbolOn);
    final Color symOff = Color(config.colors.symbolOff);

    void displaySymbol(bool isOn, String label, double left) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              color: isOn ? symOn : symOff,
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
        ),
        textScaler: const TextScaler.linear(0.8),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      textPainter.paint(canvas, Offset(left, 0.0));
    }

    void displayPixel(bool isOn, int x, int y) {
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

    void displayBuffer(Uint8ClampedList buffer, int xStart1, int xStart2) {
      int x1 = xStart1;
      int x2 = xStart2;

      for (int i = 0; i <= buffer.length - 2; i += 2, x1++, x2++) {
        final int low = buffer[i];
        displayPixel(low & 0x10 == 0x10, x1, 0);
        displayPixel(low & 0x20 == 0x20, x1, 1);
        displayPixel(low & 0x40 == 0x40, x1, 2);
        displayPixel(low & 0x80 == 0x80, x1, 3);

        displayPixel(low & 0x01 == 0x01, x2, 0);
        displayPixel(low & 0x02 == 0x02, x2, 1);
        displayPixel(low & 0x04 == 0x04, x2, 2);
        displayPixel(low & 0x08 == 0x08, x2, 3);

        final int high = buffer[i + 1];
        displayPixel(high & 0x10 == 0x10, x1, 4);
        displayPixel(high & 0x20 == 0x20, x1, 5);
        displayPixel(high & 0x40 == 0x40, x1, 6);

        displayPixel(high & 0x01 == 0x01, x2, 4);
        displayPixel(high & 0x02 == 0x02, x2, 5);
        displayPixel(high & 0x04 == 0x04, x2, 6);
      }
    }

    displayBuffer(lcdEvent.displayBuffer1, 78, 0);
    displayBuffer(lcdEvent.displayBuffer2, 117, 39);

    displaySymbol(lcdEvent.symbols.busy, 'BUSY', config.symbols.busy);
    displaySymbol(lcdEvent.symbols.shift, 'SHIFT', config.symbols.shift);
    displaySymbol(lcdEvent.symbols.small, 'SMALL', config.symbols.small);
    displaySymbol(lcdEvent.symbols.def, 'DEF', config.symbols.def);
    displaySymbol(lcdEvent.symbols.one, 'I', config.symbols.one);
    displaySymbol(lcdEvent.symbols.two, 'II', config.symbols.two);
    displaySymbol(lcdEvent.symbols.three, 'III', config.symbols.three);
    displaySymbol(lcdEvent.symbols.de, 'DE', config.symbols.de);
    displaySymbol(lcdEvent.symbols.g, 'G', config.symbols.g);
    displaySymbol(lcdEvent.symbols.rad, 'RAD', config.symbols.rad);
    displaySymbol(lcdEvent.symbols.run, 'RUN', config.symbols.run);
    displaySymbol(lcdEvent.symbols.pro, 'PRO', config.symbols.pro);
    displaySymbol(lcdEvent.symbols.reserve, 'RESERVE', config.symbols.reserve);

    // Battery indicator.
    canvas.drawCircle(
      Offset(155.0 * (config.pixels.width + config.pixels.gap), 8.0),
      3.0,
      pxOn,
    );
  }

  @override
  bool shouldRepaint(covariant _Screen oldDelegate) {
    return lcdEvent != oldDelegate.lcdEvent;
  }
}
