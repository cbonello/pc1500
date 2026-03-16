import 'dart:typed_data';

import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:roms/roms.dart';

enum MemoryAccessType { read, write }

mixin MemoryObservable {
  bool registerObserver(MemoryAccessType type, MemoryObserver observer) =>
      throw UnimplementedError();
  void notifyObservers(MemoryAccessType type, int address, int value) =>
      throw UnimplementedError();
}

mixin MemoryObserver {
  void memoryUpdated(MemoryAccessType type, int address, int value) =>
      throw UnimplementedError();
}

abstract class MemoryChipBase extends Equatable with MemoryObservable {
  MemoryChipBase._({
    required this.start,
    required this.length,
    required Uint8ClampedList data,
  }) : end = start + length - 1,
       _data = data,
       _observers = <MemoryAccessType, Set<MemoryObserver>>{
         MemoryAccessType.read: <MemoryObserver>{},
         MemoryAccessType.write: <MemoryObserver>{},
       };

  final int start;
  final int length;
  final int end;
  final Uint8ClampedList _data;
  final Map<MemoryAccessType, Set<MemoryObserver>> _observers;

  bool get isReadonly;

  // UI helper function; notifications not required.
  Uint8ClampedList readAt(int offsetInBytes, int length) =>
      _data.sublist(offsetInBytes, offsetInBytes + length);

  int readByteAt(int offsetInBytes);

  void writeByteAt(int offsetInBytes, int value);

  void restoreState(Map<String, dynamic> json);

  Map<String, dynamic> saveState();

  MemoryChipBase clone();

  @override
  bool registerObserver(MemoryAccessType type, MemoryObserver observer) =>
      _observers[type]!.add(observer);

  @override
  void notifyObservers(MemoryAccessType type, int address, int value) {
    final Set<MemoryObserver> observers = _observers[type]!;
    if (observers.isEmpty) return;
    for (final MemoryObserver observer in observers) {
      observer.memoryUpdated(type, address, value);
    }
  }

  void _checkSavedState(Map<String, dynamic> json, String expectedType) {
    final String savedType = json['type'] as String;
    final int savedStart = json['start'] as int;
    final int savedLength = json['length'] as int;

    if (savedType != expectedType ||
        savedStart != start ||
        savedLength != length) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.config,
        'Saved state does not match current configuration',
      );
    }
  }

  void _checkOffset(int offsetInBytes) {
    if (offsetInBytes < 0 || offsetInBytes >= length) {
      throw RangeError.range(offsetInBytes, 0, length - 1, 'offsetInBytes');
    }
  }

  @override
  List<Object> get props => <Object>[start, length, _data];

  @override
  bool get stringify => true;
}

class MemoryChipRam extends MemoryChipBase {
  MemoryChipRam({required super.start, required super.length})
    : super._(data: Uint8ClampedList(length));

  @override
  bool get isReadonly => false;

  @override
  int readByteAt(int offsetInBytes) {
    _checkOffset(offsetInBytes);
    final int value = _data[offsetInBytes];

    notifyObservers(MemoryAccessType.read, start + offsetInBytes, value);

    return value;
  }

  @override
  void writeByteAt(int offsetInBytes, int value) {
    _checkOffset(offsetInBytes);
    _data[offsetInBytes] = value;
    notifyObservers(MemoryAccessType.write, start + offsetInBytes, value);
  }

  @override
  void restoreState(Map<String, dynamic> json) {
    _checkSavedState(json, 'ram');

    final List<int> data = json['data'] as List<int>;
    if (data.length != length) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.config,
        'Saved data length ${data.length} does not match RAM length $length',
      );
    }
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

class MemoryChipRom extends MemoryChipBase {
  MemoryChipRom({required super.start, required RomBase rom})
    : _hash = rom.hash,
      super._(
        length: rom.bytes.length,
        data: Uint8ClampedList.fromList(rom.bytes),
      );

  MemoryChipRom._({
    required int start,
    required int length,
    required Digest hash,
  }) : _hash = hash,
       super._(start: start, length: length, data: Uint8ClampedList(length));

  final Digest _hash;

  @override
  bool get isReadonly => true;

  @override
  int readByteAt(int offsetInBytes) {
    _checkOffset(offsetInBytes);
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
    if (savedHash != _hash.toString()) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.config,
        'ROM hash mismatch',
      );
    }
  }

  @override
  Map<String, dynamic> saveState() => <String, dynamic>{
    'type': 'rom',
    'start': start,
    'length': length,
    'hash': _hash.toString(),
  };

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

class MemoryChipRomPlaceholder extends MemoryChipBase {
  MemoryChipRomPlaceholder({
    required super.start,
    required int length,
    required int value,
  }) : _value = value,
       super._(length: length, data: Uint8ClampedList(length)) {
    _data.fillRange(0, length, value);
  }

  final int _value;

  @override
  bool get isReadonly => false;

  @override
  int readByteAt(int offsetInBytes) {
    _checkOffset(offsetInBytes);
    notifyObservers(MemoryAccessType.read, start + offsetInBytes, _value);

    return _value;
  }

  @override
  void writeByteAt(int offsetInBytes, int value) {
    _checkOffset(offsetInBytes);
    notifyObservers(MemoryAccessType.write, start + offsetInBytes, value);
  }

  @override
  void restoreState(Map<String, dynamic> json) {
    _checkSavedState(json, 'io_ports');

    final int savedValue = json['value'] as int;
    if (savedValue != _value) {
      throw ChipSelectDecoderError(
        ChipSelectDecoderErrorId.config,
        'Placeholder value mismatch',
      );
    }
  }

  @override
  Map<String, dynamic> saveState() => <String, dynamic>{
    'type': 'io_ports',
    'start': start,
    'length': length,
    'value': _value,
  };

  @override
  MemoryChipBase clone() {
    final MemoryChipRomPlaceholder io = MemoryChipRomPlaceholder(
      start: start,
      length: length,
      value: _value,
    );

    return io;
  }
}
