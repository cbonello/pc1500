import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pc1500/src/pages/home/lcd.dart';

// Standard pixel dimensions matching the PC-1500A skin config.
const double _pw = 4.5; // pixel width
const double _ph = 5.0; // pixel height
const double _pg = 1.0; // gap between pixels
const double _pt = 20.0; // top offset for pixel grid

/// Helper: expected rect for a pixel at column [x], row [y].
Rect _expectedRect(int x, int y) => Rect.fromLTWH(
  x * (_pw + _pg),
  y * (_ph + _pg) + _pt,
  _pw,
  _ph,
);

void main() {
  group('collectPixelRects', () {
    test('empty buffer produces no rects', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      collectPixelRects(
        buffer: Uint8ClampedList(0),
        xStart1: 78, xStart2: 0,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      expect(on, isEmpty);
      expect(off, isEmpty);
    });

    test('all-zero buffer produces only OFF rects', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      // 2 bytes = 1 column pair = 14 pixels (7 rows × 2 columns).
      collectPixelRects(
        buffer: Uint8ClampedList(2),
        xStart1: 78, xStart2: 0,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      expect(on, isEmpty);
      expect(off, hasLength(14));
    });

    test('all-FF buffer produces only ON rects', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      collectPixelRects(
        buffer: Uint8ClampedList.fromList([0xFF, 0x7F]),
        xStart1: 78, xStart2: 0,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      // 0xFF: all 8 bits set → x1 rows 0-3 ON, x2 rows 0-3 ON.
      // 0x7F = 0111_1111: bits 0-6 set → x1 rows 4-6 ON, x2 rows 4-6 ON.
      // bit 7 of high byte is unused (only 7 rows).
      expect(on, hasLength(14));
      expect(off, isEmpty);
    });

    test('single pixel ON in x2 column', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      // Low byte bit 0 = x2 row 0 ON. Everything else OFF.
      collectPixelRects(
        buffer: Uint8ClampedList.fromList([0x01, 0x00]),
        xStart1: 78, xStart2: 0,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      expect(on, hasLength(1));
      expect(off, hasLength(13));
      // x2=0, row=0.
      expect(on.first, equals(_expectedRect(0, 0)));
    });

    test('single pixel ON in x1 column', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      // Low byte bit 4 = x1 row 0 ON.
      collectPixelRects(
        buffer: Uint8ClampedList.fromList([0x10, 0x00]),
        xStart1: 78, xStart2: 0,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      expect(on, hasLength(1));
      expect(off, hasLength(13));
      expect(on.first, equals(_expectedRect(78, 0)));
    });

    test('high byte controls rows 4-6', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      // High byte 0x01 = x2 row 4 ON. High byte 0x10 = x1 row 4 ON.
      collectPixelRects(
        buffer: Uint8ClampedList.fromList([0x00, 0x11]),
        xStart1: 78, xStart2: 0,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      expect(on, hasLength(2));
      // x2=0 row 4, x1=78 row 4.
      expect(on, contains(_expectedRect(0, 4)));
      expect(on, contains(_expectedRect(78, 4)));
    });

    test('multiple column pairs advance x1 and x2', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      // 4 bytes = 2 column pairs.
      // Pair 0: x1=78, x2=0. Pair 1: x1=79, x2=1.
      collectPixelRects(
        buffer: Uint8ClampedList.fromList([0x01, 0x00, 0x10, 0x00]),
        xStart1: 78, xStart2: 0,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      // Pair 0: x2=0 row 0 ON. Pair 1: x1=79 row 0 ON.
      expect(on, hasLength(2));
      expect(on, contains(_expectedRect(0, 0)));
      expect(on, contains(_expectedRect(79, 0)));
    });

    test('total rects for full 78-byte buffer', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      // 78 bytes = 39 pairs = 78 columns × 7 rows = 546 pixels.
      collectPixelRects(
        buffer: Uint8ClampedList(78),
        xStart1: 78, xStart2: 0,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      expect(on.length + off.length, equals(39 * 14));
    });

    test('odd buffer length ignores trailing byte', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      // 3 bytes: only first 2 are processed (1 pair). Byte 3 is ignored.
      collectPixelRects(
        buffer: Uint8ClampedList.fromList([0xFF, 0x7F, 0xFF]),
        xStart1: 0, xStart2: 100,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      expect(on, hasLength(14)); // 1 pair = 14 pixels all ON.
    });

    test('xStart offsets are applied correctly', () {
      final List<Rect> on = <Rect>[];
      final List<Rect> off = <Rect>[];
      // x2 starts at 39, x1 starts at 117 (buffer 2 layout).
      collectPixelRects(
        buffer: Uint8ClampedList.fromList([0x11, 0x00]),
        xStart1: 117, xStart2: 39,
        pxWidth: _pw, pxHeight: _ph, pxGap: _pg, pxTop: _pt,
        onRects: on, offRects: off,
      );
      // 0x11 = bit 0 (x2 row 0) + bit 4 (x1 row 0).
      expect(on, hasLength(2));
      expect(on, contains(_expectedRect(39, 0)));
      expect(on, contains(_expectedRect(117, 0)));
    });
  });
}
