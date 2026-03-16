import 'dart:async';
import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:lcd/lcd.dart';
import 'package:test/test.dart';

final Uint8ClampedList me0 = Uint8ClampedList(64 * 1024);

Uint8ClampedList memRead(int address, int length) =>
    me0.sublist(address, address + length);

void main() {
  setUp(() {
    me0.fillRange(0, me0.length, 0);
  });

  group(LcdSymbols, () {
    test('should decode LCDSYM1 bitmask correctly', () {
      // All bits set: DEF, I, II, III, SMALL, SML, SHIFT, BUSY.
      final LcdSymbols allOn = LcdSymbols(
        data: Uint8ClampedList.fromList([0xFF, 0x00]),
      );
      expect(allOn.def, isTrue);
      expect(allOn.one, isTrue);
      expect(allOn.two, isTrue);
      expect(allOn.three, isTrue);
      expect(allOn.small, isTrue);
      expect(allOn.sml, isTrue);
      expect(allOn.shift, isTrue);
      expect(allOn.busy, isTrue);

      // All bits clear.
      final LcdSymbols allOff = LcdSymbols(
        data: Uint8ClampedList.fromList([0x00, 0x00]),
      );
      expect(allOff.def, isFalse);
      expect(allOff.one, isFalse);
      expect(allOff.two, isFalse);
      expect(allOff.three, isFalse);
      expect(allOff.small, isFalse);
      expect(allOff.sml, isFalse);
      expect(allOff.shift, isFalse);
      expect(allOff.busy, isFalse);
    });

    test('should decode LCDSYM2 bitmask correctly', () {
      // RUN=0x40, PRO=0x20, RESERVE=0x10, RAD=0x04, G=0x02, DE=0x01.
      final LcdSymbols allOn = LcdSymbols(
        data: Uint8ClampedList.fromList([0x00, 0x77]),
      );
      expect(allOn.run, isTrue);
      expect(allOn.pro, isTrue);
      expect(allOn.reserve, isTrue);
      expect(allOn.rad, isTrue);
      expect(allOn.g, isTrue);
      expect(allOn.de, isTrue);

      final LcdSymbols allOff = LcdSymbols(
        data: Uint8ClampedList.fromList([0x00, 0x00]),
      );
      expect(allOff.run, isFalse);
      expect(allOff.pro, isFalse);
      expect(allOff.reserve, isFalse);
      expect(allOff.rad, isFalse);
      expect(allOff.g, isFalse);
      expect(allOff.de, isFalse);
    });

    test('props[] should contain data', () {
      final Uint8ClampedList data = Uint8ClampedList.fromList([0x01, 0x02]);
      final LcdSymbols symbols = LcdSymbols(data: data);
      expect(symbols.props, equals([data]));
    });
  });

  group(LcdEvent, () {
    test('static getters should return correct lengths', () {
      expect(LcdEvent.displayBufferLength, equals(0x4E));
      expect(LcdEvent.symbolsLength, equals(2));
      expect(LcdEvent.length, equals(0x4E + 0x4E + 2 + 1));
    });

    test('copyWith() should replace specified fields', () {
      final Uint8ClampedList buf1 = Uint8ClampedList(0x4E);
      final Uint8ClampedList buf2 = Uint8ClampedList(0x4E);
      final LcdSymbols sym = LcdSymbols(
        data: Uint8ClampedList.fromList([0, 0]),
      );
      final LcdEvent event = LcdEvent(
        displayBuffer1: buf1,
        displayBuffer2: buf2,
        symbols: sym,
        displayOn: true,
      );

      final Uint8ClampedList newBuf1 = Uint8ClampedList(0x4E)..[0] = 42;
      final LcdEvent copied = event.copyWith(displayBuffer1: newBuf1);

      expect(copied.displayBuffer1[0], equals(42));
      expect(copied.displayBuffer2, same(buf2));
      expect(copied.symbols, same(sym));
      expect(copied.displayOn, isTrue);
    });

    test('props[] should contain all fields', () {
      final Uint8ClampedList buf1 = Uint8ClampedList(0x4E);
      final Uint8ClampedList buf2 = Uint8ClampedList(0x4E);
      final LcdSymbols sym = LcdSymbols(
        data: Uint8ClampedList.fromList([0, 0]),
      );
      final LcdEvent event = LcdEvent(
        displayBuffer1: buf1,
        displayBuffer2: buf2,
        symbols: sym,
        displayOn: true,
      );
      expect(event.props, equals([buf1, buf2, sym, true]));
    });
  });

  group(Lcd, () {
    test('should be initialized successfully', () {
      final Lcd lcd = Lcd(memRead: memRead);
      expect(lcd, isA<Lcd>());
      lcd.dispose();
    });

    test('emitInitialState should emit current buffer state', () async {
      me0[0x7600] = 0xAB;
      me0[0x764E] = 0xFF;
      final Lcd lcd = Lcd(memRead: memRead);

      final Completer<LcdEvent> completer = Completer<LcdEvent>();
      lcd.events.listen(completer.complete);
      lcd.emitInitialState();

      final LcdEvent event = await completer.future;
      expect(event.displayBuffer1[0], equals(0xAB));
      expect(event.symbols.def, isTrue);
      lcd.dispose();
    });

    test('memoryUpdated should update display buffer 1', () async {
      final Lcd lcd = Lcd(memRead: memRead);

      final Completer<LcdEvent> completer = Completer<LcdEvent>();
      lcd.events.listen(completer.complete);
      lcd.memoryUpdated(MemoryAccessType.write, 0x7600, 0x42);

      // Wait for debounce timer.
      final LcdEvent event = await completer.future.timeout(
        const Duration(milliseconds: 50),
      );
      expect(event.displayBuffer1[0], equals(0x42));
      lcd.dispose();
    });

    test('memoryUpdated should update display buffer 2', () async {
      final Lcd lcd = Lcd(memRead: memRead);

      final Completer<LcdEvent> completer = Completer<LcdEvent>();
      lcd.events.listen(completer.complete);
      lcd.memoryUpdated(MemoryAccessType.write, 0x7700, 0x99);

      final LcdEvent event = await completer.future.timeout(
        const Duration(milliseconds: 50),
      );
      expect(event.displayBuffer2[0], equals(0x99));
      lcd.dispose();
    });

    test('memoryUpdated should update symbol data', () async {
      final Lcd lcd = Lcd(memRead: memRead);

      final Completer<LcdEvent> completer = Completer<LcdEvent>();
      lcd.events.listen(completer.complete);
      // Write 0x80 to LCDSYM1 (764E) → DEF symbol on.
      lcd.memoryUpdated(MemoryAccessType.write, 0x764E, 0x80);

      final LcdEvent event = await completer.future.timeout(
        const Duration(milliseconds: 50),
      );
      expect(event.symbols.def, isTrue);
      expect(event.symbols.busy, isFalse);
      lcd.dispose();
    });

    test('memoryUpdated should ignore addresses outside LCD range', () async {
      final Lcd lcd = Lcd(memRead: memRead);

      bool eventReceived = false;
      lcd.events.listen((_) => eventReceived = true);

      // Address outside any LCD buffer.
      lcd.memoryUpdated(MemoryAccessType.write, 0x7800, 0xFF);

      // Wait past debounce period — no event should fire.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(eventReceived, isFalse);
      lcd.dispose();
    });

    test('should coalesce rapid writes into a single event', () async {
      final Lcd lcd = Lcd(memRead: memRead);

      int eventCount = 0;
      lcd.events.listen((_) => eventCount++);

      // Simulate ROM writing all 78 bytes of display buffer 1.
      for (int i = 0; i < 0x4E; i++) {
        lcd.memoryUpdated(MemoryAccessType.write, 0x7600 + i, i);
      }

      // Wait for debounce.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(eventCount, equals(1));

      // Verify final state has all bytes.
      final Completer<LcdEvent> completer = Completer<LcdEvent>();
      lcd.events.listen(completer.complete);
      lcd.emitInitialState();
      final LcdEvent event = await completer.future;
      for (int i = 0; i < 0x4E; i++) {
        expect(event.displayBuffer1[i], equals(i));
      }
      lcd.dispose();
    });

    test('emitted events should be immutable snapshots', () async {
      final Lcd lcd = Lcd(memRead: memRead);

      final Completer<LcdEvent> first = Completer<LcdEvent>();
      lcd.events.listen((LcdEvent e) {
        if (!first.isCompleted) first.complete(e);
      });

      lcd.memoryUpdated(MemoryAccessType.write, 0x7600, 0xAA);
      final LcdEvent event1 = await first.future.timeout(
        const Duration(milliseconds: 50),
      );

      // Write a different value — should not mutate the already-emitted event.
      lcd.memoryUpdated(MemoryAccessType.write, 0x7600, 0xBB);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(event1.displayBuffer1[0], equals(0xAA));
      lcd.dispose();
    });

    test('dispose() should cancel pending timer', () async {
      final Lcd lcd = Lcd(memRead: memRead);

      bool eventReceived = false;
      lcd.events.listen((_) => eventReceived = true);

      lcd.memoryUpdated(MemoryAccessType.write, 0x7600, 0xFF);
      lcd.dispose();

      // Wait past debounce — event should not fire after dispose.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(eventReceived, isFalse);
    });
  });
}
