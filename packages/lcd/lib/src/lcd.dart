import 'dart:async';
import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

const int _dispBuf1Start = 0x07600;
const int _dispBuf2Start = 0x07700;
const int _dispBufLen = 0x4E;
const int _symBufStart = 0x0764E;
const int _symBufLen = 2;

typedef MemoryReadFn = Uint8ClampedList Function(int address, int length);

@immutable
class LcdSymbols extends Equatable {
  const LcdSymbols({required this.data}) : assert(data.length == _symBufLen);

  final Uint8ClampedList data;

  bool get def => (data[0] & 0x80) != 0;
  bool get one => (data[0] & 0x40) != 0;
  bool get two => (data[0] & 0x20) != 0;
  bool get three => (data[0] & 0x10) != 0;
  bool get small => (data[0] & 0x08) != 0;
  bool get sml => (data[0] & 0x04) != 0;
  bool get shift => (data[0] & 0x02) != 0;
  bool get busy => (data[0] & 0x01) != 0;

  bool get run => (data[1] & 0x40) != 0;
  bool get pro => (data[1] & 0x20) != 0;
  bool get reserve => (data[1] & 0x10) != 0;
  bool get rad => (data[1] & 0x04) != 0;
  bool get g => (data[1] & 0x02) != 0;
  bool get de => (data[1] & 0x01) != 0;

  @override
  List<Object> get props => <Object>[data];
}

@immutable
class LcdEvent extends Equatable {
  const LcdEvent({
    required this.displayBuffer1,
    required this.displayBuffer2,
    required this.symbols,
  }) : assert(displayBuffer1.length == _dispBufLen),
       assert(displayBuffer2.length == _dispBufLen);

  final Uint8ClampedList displayBuffer1;
  final Uint8ClampedList displayBuffer2;
  final LcdSymbols symbols;

  static int get length => _dispBufLen + _dispBufLen + _symBufLen;
  static int get displayBufferLength => _dispBufLen;
  static int get symbolsLength => _symBufLen;

  LcdEvent copyWith({
    Uint8ClampedList? displayBuffer1,
    Uint8ClampedList? displayBuffer2,
    LcdSymbols? symbols,
  }) => LcdEvent(
    displayBuffer1: displayBuffer1 ?? this.displayBuffer1,
    displayBuffer2: displayBuffer2 ?? this.displayBuffer2,
    symbols: symbols ?? this.symbols,
  );

  @override
  List<Object> get props => <Object>[displayBuffer1, displayBuffer2, symbols];
}

class Lcd with MemoryObserver {
  factory Lcd({required MemoryReadFn memRead}) => Lcd._(
    displayBuffer1: memRead(_dispBuf1Start, _dispBufLen),
    displayBuffer2: memRead(_dispBuf2Start, _dispBufLen),
    symbolData: memRead(_symBufStart, _symBufLen),
  );

  Lcd._({
    required Uint8ClampedList displayBuffer1,
    required Uint8ClampedList displayBuffer2,
    required Uint8ClampedList symbolData,
  }) : assert(displayBuffer1.length == _dispBufLen),
       assert(displayBuffer2.length == _dispBufLen),
       assert(symbolData.length == _symBufLen),
       _displayBuffer1 = displayBuffer1,
       _displayBuffer2 = displayBuffer2,
       _symbolData = symbolData,
       _eventCtrl = StreamController<LcdEvent>.broadcast();

  /// Emits the current LCD state to all listeners.
  /// Call after subscribing to [events] to receive the initial state.
  void emitInitialState() => _emitSnapshot();

  final Uint8ClampedList _displayBuffer1;
  final Uint8ClampedList _displayBuffer2;
  final Uint8ClampedList _symbolData;
  final StreamController<LcdEvent> _eventCtrl;
  Timer? _debounceTimer;
  bool _dirty = false;

  Stream<LcdEvent> get events => _eventCtrl.stream;

  @override
  void memoryUpdated(MemoryAccessType type, int address, int value) {
    if (address >= _dispBuf1Start && address < _dispBuf1Start + _dispBufLen) {
      _displayBuffer1[address - _dispBuf1Start] = value;
    } else if (address >= _dispBuf2Start &&
        address < _dispBuf2Start + _dispBufLen) {
      _displayBuffer2[address - _dispBuf2Start] = value;
    } else if (address >= _symBufStart &&
        address < _symBufStart + _symBufLen) {
      _symbolData[address - _symBufStart] = value;
    } else {
      return;
    }
    _markDirty();
  }

  /// Coalesces rapid writes into a single event emission.
  /// No intermediate LcdEvent objects are allocated until the timer fires.
  void _markDirty() {
    if (_dirty) return;
    _dirty = true;
    _debounceTimer ??= Timer(const Duration(milliseconds: 12), () {
      _debounceTimer = null;
      _dirty = false;
      _emitSnapshot();
    });
  }

  /// Takes a snapshot of current buffer state and emits it.
  /// Copies the buffers so the event is immutable.
  void _emitSnapshot() {
    _eventCtrl.add(
      LcdEvent(
        displayBuffer1: Uint8ClampedList.fromList(_displayBuffer1),
        displayBuffer2: Uint8ClampedList.fromList(_displayBuffer2),
        symbols: LcdSymbols(data: Uint8ClampedList.fromList(_symbolData)),
      ),
    );
  }

  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _eventCtrl.close();
  }
}
