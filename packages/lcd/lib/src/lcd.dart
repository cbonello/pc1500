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
    int address,
    int value,
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
      notifyObservers(LcdEventType.displayBufferUpdated(address, value));
    } else if (address >= 0x0764E && address <= 0x0764f) {
      notifyObservers(LcdEventType.symbolsUpdated(getSymbols()));
    }
  }

  List<int> getDisplayBuffer1() => _readMemoryArea(0x07600, 0x0764D);

  List<int> getDisplayBuffer2() => _readMemoryArea(0x07700, 0x0774D);

  LcdSymbols getSymbols() {
    final int addr764E = _memRead(0x0764E);
    final int addr764F = _memRead(0x0764F);

    return LcdSymbols(
      def: (addr764E & 0x80) != 0,
      one: (addr764E & 0x40) != 0,
      two: (addr764E & 0x20) != 0,
      three: (addr764E & 0x10) != 0,
      small: (addr764E & 0x08) != 0,
      sml: (addr764E & 0x04) != 0,
      shift: (addr764E & 0x02) != 0,
      busy: (addr764E & 0x01) != 0,
      run: (addr764F & 0x40) != 0,
      pro: (addr764F & 0x20) != 0,
      reserve: (addr764F & 0x10) != 0,
      rad: (addr764F & 0x04) != 0,
      g: (addr764F & 0x02) != 0,
      de: (addr764F & 0x01) != 0,
    );
  }

  List<int> _readMemoryArea(int startAddr, int endAddr) {
    final List<int> buffer = List<int>(endAddr - startAddr + 1);

    for (int address = startAddr, i = 0; address <= endAddr; address++, i++) {
      buffer[i] = _memRead(address);
    }
    return buffer;
  }
}
