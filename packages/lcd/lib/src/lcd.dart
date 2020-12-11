import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

part 'lcd.freezed.dart';

class LcdSymbols {
  LcdSymbols({
    this.def = false,
    this.one = false,
    this.two = false,
    this.three = false,
    this.small = false,
    this.sml = false,
    this.shift = false,
    this.busy = false,
    this.run = false,
    this.pro = false,
    this.reserve = false,
    this.rad = false,
    this.g = false,
    this.de = false,
  });

  bool def;
  bool one;
  bool two;
  bool three;
  bool small;
  bool sml;
  bool shift;
  bool busy;
  bool run;
  bool pro;
  bool reserve;
  bool rad;
  bool g;
  bool de;
}

@freezed
abstract class LcdEventType with _$LcdEventType {
  const factory LcdEventType.displayBufferUpdated(
    Uint8ClampedList displayBuffer1,
    Uint8ClampedList displayBuffer2,
  ) = _DisplayBufferUpdated;

  const factory LcdEventType.symbolsUpdated(
    LcdSymbols symbols,
  ) = _SymbolUpdated;
}

mixin LcdObservable {
  bool registerObserver(LcdObserver observer) => throw UnimplementedError;

  void notifyObservers(LcdEventType event) => throw UnimplementedError;
}

mixin LcdObserver {
  void displayBufferUpdated(LcdEventType event) => throw UnimplementedError;
}

class Lcd with LcdObservable, MemoryObserver {
  Lcd({@required MemoryRead memRead})
      : assert(memRead != null),
        _memRead = memRead,
        _observers = <LcdObserver>{};

  final MemoryRead _memRead;
  final Set<LcdObserver> _observers;

  @override
  bool registerObserver(LcdObserver observer) => _observers.add(observer);

  @override
  void notifyObservers(LcdEventType event) {
    for (final LcdObserver observer in _observers) {
      observer.displayBufferUpdated(event);
    }
  }

  @override
  void memoryUpdated(MemoryAccessType type, int address, int value) {
    if ((address >= 0x07600 && address <= 0x0764D) ||
        (address >= 0x07700 && address <= 0x0774D)) {
      notifyObservers(LcdEventType.displayBufferUpdated(
        getDisplayBuffer1(),
        getDisplayBuffer2(),
      ));
    } else if (address >= 0x0764E && address <= 0x0764f) {
      notifyObservers(LcdEventType.symbolsUpdated(getSymbols()));
    }
  }

  Uint8ClampedList getDisplayBuffer1() => _memRead(0x07600, 0x4D);

  Uint8ClampedList getDisplayBuffer2() => _memRead(0x07700, 0x4D);

  LcdSymbols getSymbols() {
    final Uint8ClampedList addr = _memRead(0x0764E, 2);

    return LcdSymbols(
      def: (addr[0] & 0x80) != 0,
      one: (addr[0] & 0x40) != 0,
      two: (addr[0] & 0x20) != 0,
      three: (addr[0] & 0x10) != 0,
      small: (addr[0] & 0x08) != 0,
      sml: (addr[0] & 0x04) != 0,
      shift: (addr[0] & 0x02) != 0,
      busy: (addr[0] & 0x01) != 0,
      run: (addr[1] & 0x40) != 0,
      pro: (addr[1] & 0x20) != 0,
      reserve: (addr[1] & 0x10) != 0,
      rad: (addr[1] & 0x04) != 0,
      g: (addr[1] & 0x02) != 0,
      de: (addr[1] & 0x01) != 0,
    );
  }
}
