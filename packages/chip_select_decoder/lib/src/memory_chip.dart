import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:roms/roms.dart';

import '../chip_select_decoder.dart';

mixin MemoryOperations {
  bool get isReadonly => throw UnimplementedError();
  int readByteAt(int offsetInBytes) => throw UnimplementedError();
  void writeByteAt(int offsetInBytes, int value) => throw UnimplementedError();
  void restoreState(Map<String, dynamic> json) => throw UnimplementedError();
  Map<String, dynamic> saveState() => throw UnimplementedError();
}

enum MemoryAccessType { read, write }

mixin MemoryObservable {
  bool registerObserver(MemoryAccessType type, MemoryObserver observer) =>
      throw UnimplementedError;
  void notifyObservers(MemoryAccessType type, int address, int value) =>
      throw UnimplementedError;
}

mixin MemoryObserver {
  void update(MemoryAccessType type, int address, int value) =>
      throw UnimplementedError;
}

abstract class MemoryChipBase extends Equatable with MemoryObservable {
  MemoryChipBase._({
    @required this.start,
    @required this.length,
    @required Uint8ClampedList data,
  })  : assert(data != null),
        _data = data,
        _observers = <MemoryAccessType, Set<MemoryObserver>>{
          MemoryAccessType.read: <MemoryObserver>{},
          MemoryAccessType.write: <MemoryObserver>{},
        };

  final int start;
  final int length;
  final Uint8ClampedList _data;
  final Map<MemoryAccessType, Set<MemoryObserver>> _observers;

  bool get isReadonly;

  int get end => start + length - 1;

  int readByteAt(int offsetInBytes);

  void writeByteAt(int offsetInBytes, int value);

  void restoreState(Map<String, dynamic> json) {
    final int savedStart = json['start'] as int;
    final int savedLength = json['length'] as int;
    final bool savedReadOnly = json['readOnly'] as bool;

    if (savedStart != start ||
        savedLength != length ||
        savedReadOnly != isReadonly) {
      throw Exception;
    }

    final List<int> data = json['data'] as List<int>;
    _data.setRange(0, length, data);
  }

  Map<String, dynamic> saveState();

  MemoryChipBase clone();

  @override
  bool registerObserver(
    MemoryAccessType type,
    MemoryObserver observer,
  ) =>
      _observers[type].add(observer);

  @override
  void notifyObservers(MemoryAccessType type, int address, int value) {
    for (final MemoryObserver observer in _observers[type]) {
      observer.update(type, address, value);
    }
  }

  void _checkSavedState(Map<String, dynamic> json, String expectedType) {
    final String savedType = json['type'] as String;
    final int savedStart = json['start'] as int;
    final int savedLength = json['length'] as int;

    if (savedType != expectedType ||
        savedStart != start ||
        savedLength != length) {
      throw Exception;
    }
  }

  @override
  List<Object> get props => <Object>[
        start,
        length,
        isReadonly,
        _data,
        _observers,
      ];

  @override
  bool get stringify => true;
}

class MemoryChipRam extends MemoryChipBase with MemoryOperations {
  MemoryChipRam({@required int start, @required int length})
      : super._(
          start: start,
          length: length,
          data: Uint8ClampedList(length),
        );

  @override
  bool get isReadonly => false;

  @override
  int readByteAt(int offsetInBytes) {
    final int value = _data[offsetInBytes];

    notifyObservers(MemoryAccessType.read, start + offsetInBytes, value);
    return value;
  }

  @override
  void writeByteAt(int offsetInBytes, int value) {
    _data[offsetInBytes] = value;
    notifyObservers(MemoryAccessType.write, start + offsetInBytes, value);
  }

  @override
  void restoreState(Map<String, dynamic> json) {
    _checkSavedState(json, 'ram');

    final List<int> data = json['data'] as List<int>;
    _data.setRange(0, length, data);
  }

  @override
  Map<String, dynamic> saveState() {
    return <String, dynamic>{
      'type': 'ram',
      'start': start,
      'length': length,
      'data': List<int>.from(_data),
    };
  }

  @override
  MemoryChipBase clone() {
    final MemoryChipRam ram = MemoryChipRam(start: start, length: length);
    ram._data.setRange(0, length, _data);
    return ram;
  }
}

class MemoryChipRom extends MemoryChipBase with MemoryOperations {
  MemoryChipRom({@required int start, @required RomBase rom})
      : _hash = rom.hash,
        super._(
          start: start,
          length: rom.bytes.length,
          data: Uint8ClampedList.fromList(rom.bytes),
        );

  MemoryChipRom._({
    @required int start,
    @required int length,
    @required Digest hash,
  })  : _hash = hash,
        super._(
          start: start,
          length: length,
          data: Uint8ClampedList(length),
        );

  final Digest _hash;

  @override
  bool get isReadonly => true;

  @override
  int readByteAt(int offsetInBytes) {
    final int value = _data[offsetInBytes];

    notifyObservers(MemoryAccessType.read, start + offsetInBytes, value);
    return value;
  }

  @override
  void writeByteAt(int offsetInBytes, int value) {
    throw ChipSelectDecoderError(
      ChipSelectDecoderErrorId.write,
      'Cannot write to ROM',
    );
  }

  @override
  void restoreState(Map<String, dynamic> json) {
    _checkSavedState(json, 'rom');

    final String savedHash = json['hash'] as String;
    if (savedHash != _hash.toString()) throw Exception();
  }

  @override
  Map<String, dynamic> saveState() {
    return <String, dynamic>{
      'type': 'rom',
      'start': start,
      'length': length,
      'hash': _hash.toString(),
    };
  }

  @override
  MemoryChipBase clone() {
    final MemoryChipRom rom = MemoryChipRom._(
      start: start,
      length: length,
      hash: _hash,
    );
    rom._data.setRange(0, length, _data);
    return rom;
  }
}

class MemoryChipIOPorts extends MemoryChipBase {
  MemoryChipIOPorts({
    @required int start,
    @required int length,
    @required int value,
  })  : _value = value,
        super._(
          start: start,
          length: length,
          data: Uint8ClampedList(length),
        ) {
    _data.fillRange(0, length, value);
  }

  final int _value;

  @override
  bool get isReadonly => false;

  @override
  int readByteAt(int offsetInBytes) {
    notifyObservers(MemoryAccessType.read, start + offsetInBytes, _value);
    return _value;
  }

  @override
  void writeByteAt(int offsetInBytes, int value) =>
      notifyObservers(MemoryAccessType.write, start + offsetInBytes, value);

  @override
  void restoreState(Map<String, dynamic> json) {
    _checkSavedState(json, 'io_ports');

    final int savedValue = json['value'] as int;
    if (savedValue != _value) throw Exception();
  }

  @override
  Map<String, dynamic> saveState() {
    return <String, dynamic>{
      'type': 'io_ports',
      'start': start,
      'length': length,
      'value': _value,
    };
  }

  @override
  MemoryChipBase clone() {
    final MemoryChipIOPorts io = MemoryChipIOPorts(
      start: start,
      length: length,
      value: _value,
    );
    return io;
  }
}
