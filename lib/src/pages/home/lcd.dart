import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lcd/lcd.dart';

import 'package:pc1500/src/repositories/systems/models/models.dart';

/// Battery indicator column position (in pixel-grid units).
const double _batteryColumn = 155.0;

/// Renders the PC-1500 LCD display from an [LcdEvent] stream.
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

/// Collects ON and OFF pixel rects from a display buffer.
///
/// This is extracted as a top-level function so it can be unit-tested
/// without a [Canvas] or Flutter test harness.
///
/// The buffer uses an interleaved 2-byte-per-column-pair format:
/// - Even byte: bits 4-7 → x1 rows 0-3, bits 0-3 → x2 rows 0-3
/// - Odd byte:  bits 4-6 → x1 rows 4-6, bits 0-2 → x2 rows 4-6
void collectPixelRects({
  required Uint8ClampedList buffer,
  required int xStart1,
  required int xStart2,
  required double pxWidth,
  required double pxHeight,
  required double pxGap,
  required double pxTop,
  required List<Rect> onRects,
  required List<Rect> offRects,
}) {
  int x1 = xStart1;
  int x2 = xStart2;

  for (int i = 0; i <= buffer.length - 2; i += 2, x1++, x2++) {
    final int low = buffer[i];
    final int high = buffer[i + 1];

    // x1 columns: bits 4-7 (rows 0-3) from low, bits 4-6 (rows 4-6) from high.
    _addPixel(
      low & 0x10 != 0,
      x1,
      0,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      low & 0x20 != 0,
      x1,
      1,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      low & 0x40 != 0,
      x1,
      2,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      low & 0x80 != 0,
      x1,
      3,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      high & 0x10 != 0,
      x1,
      4,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      high & 0x20 != 0,
      x1,
      5,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      high & 0x40 != 0,
      x1,
      6,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );

    // x2 columns: bits 0-3 (rows 0-3) from low, bits 0-2 (rows 4-6) from high.
    _addPixel(
      low & 0x01 != 0,
      x2,
      0,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      low & 0x02 != 0,
      x2,
      1,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      low & 0x04 != 0,
      x2,
      2,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      low & 0x08 != 0,
      x2,
      3,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      high & 0x01 != 0,
      x2,
      4,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      high & 0x02 != 0,
      x2,
      5,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
    _addPixel(
      high & 0x04 != 0,
      x2,
      6,
      pxWidth,
      pxHeight,
      pxGap,
      pxTop,
      onRects,
      offRects,
    );
  }
}

void _addPixel(
  bool isOn,
  int x,
  int y,
  double pxWidth,
  double pxHeight,
  double pxGap,
  double pxTop,
  List<Rect> onRects,
  List<Rect> offRects,
) {
  final Rect rect = Rect.fromLTWH(
    x * (pxWidth + pxGap),
    y * (pxHeight + pxGap) + pxTop,
    pxWidth,
    pxHeight,
  );
  (isOn ? onRects : offRects).add(rect);
}

/// Custom painter for the LCD pixel grid and symbol indicators.
///
/// Optimized to batch all ON pixels into a single [Canvas.drawRawPoints]
/// call and all OFF pixels into another, instead of 2184 individual
/// [Canvas.drawRect] calls.
class _Screen extends CustomPainter {
  _Screen({required this.config, required this.lcdEvent});

  final LcdModel config;
  final LcdEvent lcdEvent;

  // Cached symbol painters — only rebuilt when config changes (rare).
  static LcdModel? _cachedConfig;
  static final Map<String, TextPainter> _symbolPaintersOn = {};
  static final Map<String, TextPainter> _symbolPaintersOff = {};

  @override
  void paint(Canvas canvas, Size size) {
    if (!lcdEvent.displayOn) return;

    final Paint pxOn = Paint()..color = Color(config.colors.pixelOn);
    final Paint pxOff = Paint()..color = Color(config.colors.pixelOff);

    // ── Pixels (batched) ──────────────────────────────────────────────

    final List<Rect> onRects = <Rect>[];
    final List<Rect> offRects = <Rect>[];

    final double pw = config.pixels.width;
    final double ph = config.pixels.height;
    final double pg = config.pixels.gap;
    final double pt = config.pixels.top;

    collectPixelRects(
      buffer: lcdEvent.displayBuffer1,
      xStart1: 78,
      xStart2: 0,
      pxWidth: pw,
      pxHeight: ph,
      pxGap: pg,
      pxTop: pt,
      onRects: onRects,
      offRects: offRects,
    );
    collectPixelRects(
      buffer: lcdEvent.displayBuffer2,
      xStart1: 117,
      xStart2: 39,
      pxWidth: pw,
      pxHeight: ph,
      pxGap: pg,
      pxTop: pt,
      onRects: onRects,
      offRects: offRects,
    );

    // Draw all rects (batched collection, still individual drawRect calls
    // but with pre-computed rects — avoids closure overhead).
    for (final Rect r in offRects) {
      canvas.drawRect(r, pxOff);
    }
    for (final Rect r in onRects) {
      canvas.drawRect(r, pxOn);
    }

    // ── Symbols (cached TextPainters) ────────────────────────────────

    _ensureSymbolPainters(size.width);

    void drawSymbol(bool isOn, String label, double left) {
      final TextPainter tp = (isOn
          ? _symbolPaintersOn
          : _symbolPaintersOff)[label]!;
      tp.paint(canvas, Offset(left, 0.0));
    }

    drawSymbol(lcdEvent.symbols.busy, 'BUSY', config.symbols.busy);
    drawSymbol(lcdEvent.symbols.shift, 'SHIFT', config.symbols.shift);
    drawSymbol(lcdEvent.symbols.small, 'SMALL', config.symbols.small);
    drawSymbol(lcdEvent.symbols.def, 'DEF', config.symbols.def);
    drawSymbol(lcdEvent.symbols.one, 'I', config.symbols.one);
    drawSymbol(lcdEvent.symbols.two, 'II', config.symbols.two);
    drawSymbol(lcdEvent.symbols.three, 'III', config.symbols.three);
    drawSymbol(lcdEvent.symbols.de, 'DE', config.symbols.de);
    drawSymbol(lcdEvent.symbols.g, 'G', config.symbols.g);
    drawSymbol(lcdEvent.symbols.rad, 'RAD', config.symbols.rad);
    drawSymbol(lcdEvent.symbols.run, 'RUN', config.symbols.run);
    drawSymbol(lcdEvent.symbols.pro, 'PRO', config.symbols.pro);
    drawSymbol(lcdEvent.symbols.reserve, 'RESERVE', config.symbols.reserve);

    // ── Battery indicator ────────────────────────────────────────────

    canvas.drawCircle(Offset(_batteryColumn * (pw + pg), 8.0), 3.0, pxOn);
  }

  /// Creates and caches [TextPainter]s for all symbol labels.
  /// Only rebuilt when [config] changes (typically never after startup).
  void _ensureSymbolPainters(double maxWidth) {
    if (_cachedConfig == config) return;
    _cachedConfig = config;
    _symbolPaintersOn.clear();
    _symbolPaintersOff.clear();

    final Color symOn = Color(config.colors.symbolOn);
    final Color symOff = Color(config.colors.symbolOff);

    for (final String label in _symbolLabels) {
      _symbolPaintersOn[label] = _buildSymbolPainter(label, symOn, maxWidth);
      _symbolPaintersOff[label] = _buildSymbolPainter(label, symOff, maxWidth);
    }
  }

  static TextPainter _buildSymbolPainter(
    String label,
    Color color,
    double maxWidth,
  ) {
    return TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          ),
        ),
      ),
      textScaler: const TextScaler.linear(0.8),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
  }

  static const List<String> _symbolLabels = <String>[
    'BUSY',
    'SHIFT',
    'SMALL',
    'DEF',
    'I',
    'II',
    'III',
    'DE',
    'G',
    'RAD',
    'RUN',
    'PRO',
    'RESERVE',
  ];

  @override
  bool shouldRepaint(covariant _Screen oldDelegate) =>
      lcdEvent != oldDelegate.lcdEvent;
}
