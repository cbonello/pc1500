import 'dart:async';
import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const int _dispBuf1Start = 0x07600;
const int _dispBuf2Start = 0x07700;
const int _dispBufLen = 0x4E;
const int _symBufStart = 0x0764E;
const int _symBufLen = 2;

@immutable
class LcdSymbols extends Equatable {
  const LcdSymbols({@required this.data}) : assert(data?.length == _symBufLen);

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
    @required this.displayBuffer1,
    @required this.displayBuffer2,
    @required this.symbols,
  })  : assert(displayBuffer1?.length == _dispBufLen),
        assert(displayBuffer2?.length == _dispBufLen),
        assert(symbols != null);

  final Uint8ClampedList displayBuffer1;
  final Uint8ClampedList displayBuffer2;
  final LcdSymbols symbols;

  LcdEvent copyWith({
    Uint8ClampedList displayBuffer1,
    Uint8ClampedList displayBuffer2,
    LcdSymbols symbols,
  }) {
    return LcdEvent(
      displayBuffer1: displayBuffer1 ?? this.displayBuffer1,
      displayBuffer2: displayBuffer2 ?? this.displayBuffer2,
      symbols: symbols ?? this.symbols,
    );
  }

  @override
  List<Object> get props => <Object>[displayBuffer1, displayBuffer2, symbols];
}

class Lcd with MemoryObserver {
  factory Lcd({@required MemoryRead memRead}) {
    assert(memRead != null);

    print('#### $_dispBufLen ${memRead(_dispBuf1Start, _dispBufLen).length}');

    return Lcd._(
      displayBuffer1: memRead(_dispBuf1Start, _dispBufLen),
      displayBuffer2: memRead(_dispBuf2Start, _dispBufLen),
      symbols: LcdSymbols(data: memRead(_symBufStart, _symBufLen)),
      memRead: memRead,
    );
  }

  Lcd._({
    @required Uint8ClampedList displayBuffer1,
    @required Uint8ClampedList displayBuffer2,
    @required LcdSymbols symbols,
    @required MemoryRead memRead,
  })  : assert(displayBuffer1?.length == _dispBufLen),
        assert(displayBuffer2?.length == _dispBufLen),
        assert(symbols != null),
        assert(memRead != null),
        _displayBuffer1 = displayBuffer1,
        _displayBuffer2 = displayBuffer2,
        _symbols = symbols,
        _memRead = memRead,
        _inEventCtrl = StreamController<LcdEvent>(),
        _outEventCtrl = BehaviorSubject<LcdEvent>() {
    _inEventCtrl.stream
        .debounceTime(const Duration(milliseconds: 12))
        .listen((LcdEvent event) => _outEventCtrl.add(event));
    _emitEvent();
  }

  final MemoryRead _memRead;
  final StreamController<LcdEvent> _inEventCtrl;
  final BehaviorSubject<LcdEvent> _outEventCtrl;
  Uint8ClampedList _displayBuffer1;
  Uint8ClampedList _displayBuffer2;
  LcdSymbols _symbols;

  Stream<LcdEvent> get events => _outEventCtrl.stream;

  @override
  void memoryUpdated(MemoryAccessType type, int address, int value) {
    assert(type == MemoryAccessType.write);

    if (_isAddressInRange(address, _dispBuf1Start, _dispBufLen)) {
      _displayBuffer1[address - _dispBuf1Start] = value;
      _emitEvent();
    } else if (_isAddressInRange(address, _dispBuf2Start, _dispBufLen)) {
      _displayBuffer2[address - _dispBuf2Start] = value;
      _emitEvent();
    } else if (_isAddressInRange(address, _symBufStart, _symBufLen)) {
      _symbols = LcdSymbols(data: _memRead(_symBufStart, _symBufLen));
      _emitEvent();
    }
  }

  void _emitEvent() => _inEventCtrl.add(
        LcdEvent(
          displayBuffer1: _displayBuffer1,
          displayBuffer2: _displayBuffer2,
          symbols: _symbols,
        ),
      );

  bool _isAddressInRange(int address, int start, int length) =>
      address >= start && address < (start + length);

  void dispose() {
    _outEventCtrl.close();
    _inEventCtrl.close();
  }
}
