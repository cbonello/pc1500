import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/pages/home/lcd.dart';

void main() {
  group('collectPixelRects', () {
    // Helper: create a 2-byte buffer and collect rects.
    ({List<Rect> on, List<Rect> off}) collect(
      int low,
      int high, {
      int xStart1 = 0,
      int xStart2 = 1,
      double pxWidth = 2.0,
      double pxHeight = 3.0,
      double pxGap = 1.0,
      double pxTop = 0.0,
    }) {
      final onRects = <Rect>[];
      final offRects = <Rect>[];
      collectPixelRects(
        buffer: Uint8ClampedList.fromList(<int>[low, high]),
        xStart1: xStart1,
        xStart2: xStart2,
        pxWidth: pxWidth,
        pxHeight: pxHeight,
        pxGap: pxGap,
        pxTop: pxTop,
        onRects: onRects,
        offRects: offRects,
      );

      return (on: onRects, off: offRects);
    }

    test('all zeros produces 14 OFF rects and 0 ON rects', () {
      final result = collect(0x00, 0x00);

      // 2 columns × 7 rows = 14 pixels total.
      expect(result.on, isEmpty);
      expect(result.off.length, equals(14));
    });

    test('all bits set produces 14 ON rects and 0 OFF rects', () {
      // low=0xFF → x1 rows 0-3 ON, x2 rows 0-3 ON.
      // high=0x77 → x1 rows 4-6 ON, x2 rows 4-6 ON.
      final result = collect(0xFF, 0x77);

      expect(result.on.length, equals(14));
      expect(result.off, isEmpty);
    });

    test('x1 column uses bits 4-7 of low byte for rows 0-3', () {
      // bit 4 (0x10) → x1, row 0 ON.
      var result = collect(0x10, 0x00);
      expect(result.on.length, equals(1));

      // bit 5 (0x20) → x1, row 1 ON.
      result = collect(0x20, 0x00);
      expect(result.on.length, equals(1));

      // bit 6 (0x40) → x1, row 2 ON.
      result = collect(0x40, 0x00);
      expect(result.on.length, equals(1));

      // bit 7 (0x80) → x1, row 3 ON.
      result = collect(0x80, 0x00);
      expect(result.on.length, equals(1));
    });

    test('x1 column uses bits 4-6 of high byte for rows 4-6', () {
      // bit 4 (0x10) → x1, row 4 ON.
      var result = collect(0x00, 0x10);
      expect(result.on.length, equals(1));

      // bit 5 (0x20) → x1, row 5 ON.
      result = collect(0x00, 0x20);
      expect(result.on.length, equals(1));

      // bit 6 (0x40) → x1, row 6 ON.
      result = collect(0x00, 0x40);
      expect(result.on.length, equals(1));
    });

    test('x2 column uses bits 0-3 of low byte for rows 0-3', () {
      // bit 0 (0x01) → x2, row 0 ON.
      var result = collect(0x01, 0x00);
      expect(result.on.length, equals(1));

      // bit 3 (0x08) → x2, row 3 ON.
      result = collect(0x08, 0x00);
      expect(result.on.length, equals(1));
    });

    test('x2 column uses bits 0-2 of high byte for rows 4-6', () {
      // bit 0 (0x01) → x2, row 4 ON.
      var result = collect(0x00, 0x01);
      expect(result.on.length, equals(1));

      // bit 2 (0x04) → x2, row 6 ON.
      result = collect(0x00, 0x04);
      expect(result.on.length, equals(1));
    });

    test('rect positions use xStart offsets', () {
      // x1=10, x2=20, single pixel in each column.
      final result = collect(
        0x11, // x1 row 0 (bit 4) + x2 row 0 (bit 0)
        0x00,
        xStart1: 10,
        xStart2: 20,
      );

      expect(result.on.length, equals(2));
      // x1 pixel at column 10: left = 10 * (2.0 + 1.0) = 30.0
      expect(result.on[0].left, equals(30.0));
      // x2 pixel at column 20: left = 20 * (2.0 + 1.0) = 60.0
      expect(result.on[1].left, equals(60.0));
    });

    test('rect dimensions match pxWidth and pxHeight', () {
      final result = collect(0x10, 0x00, pxWidth: 5.0, pxHeight: 7.0);

      expect(result.on.length, equals(1));
      expect(result.on[0].width, equals(5.0));
      expect(result.on[0].height, equals(7.0));
    });

    test('pxTop offsets the y position', () {
      final result = collect(0x10, 0x00, pxTop: 10.0);

      expect(result.on.length, equals(1));
      // Row 0 with pxTop=10: top = 0 * (3.0 + 1.0) + 10.0 = 10.0
      expect(result.on[0].top, equals(10.0));
    });

    test('multi-byte buffer processes all column pairs', () {
      // 4-byte buffer = 2 column pairs = 4 columns × 7 rows = 28 pixels.
      final List<Rect> onRects = <Rect>[];
      final List<Rect> offRects = <Rect>[];
      collectPixelRects(
        buffer: Uint8ClampedList.fromList(<int>[0x00, 0x00, 0x00, 0x00]),
        xStart1: 0,
        xStart2: 100,
        pxWidth: 1.0,
        pxHeight: 1.0,
        pxGap: 0.0,
        pxTop: 0.0,
        onRects: onRects,
        offRects: offRects,
      );

      expect(offRects.length, equals(28));
    });
  });
}
