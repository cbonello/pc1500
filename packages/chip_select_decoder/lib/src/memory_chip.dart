import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

mixin MemoryOperations {
  bool get isReadonly => throw UnimplementedError;
  int readByteAt(int offsetInBytes) => throw UnimplementedError;
  void writeByteAt(int offsetInBytes, int value) => throw UnimplementedError;
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

class MemoryChip extends Equatable with MemoryOperations, MemoryObservable {
  MemoryChip._({
    @required this.start,
    @required this.length,
    @required bool isReadonly,
    @required Uint8ClampedList data,
  })  : _isReadonly = isReadonly,
        assert(data != null),
        _data = data,
        _observers = <MemoryAccessType, Set<MemoryObserver>>{
          MemoryAccessType.read: <MemoryObserver>{},
          MemoryAccessType.write: <MemoryObserver>{},
        };

  factory MemoryChip.ram({@required int start, @required int length}) =>
      MemoryChip._(
        start: start,
        length: length,
        isReadonly: false,
        data: Uint8ClampedList(length),
      );

  factory MemoryChip.rom({@required int start, @required Uint8List content}) =>
      MemoryChip._(
        start: start,
        length: content.length,
        isReadonly: true,
        data: Uint8ClampedList.fromList(content),
      );

  final int start;
  final int length;
  final bool _isReadonly;
  final Uint8ClampedList _data;
  final Map<MemoryAccessType, Set<MemoryObserver>> _observers;

  int get end => start + length - 1;

  void restoreState(Map<String, dynamic> json) {
    final int savedStart = json['start'] as int;
    final int savedLength = json['length'] as int;
    final bool savedReadOnly = json['readOnly'] as bool;

    if (savedStart != start ||
        savedLength != length ||
        savedReadOnly != _isReadonly) {
      throw Exception;
    }

    final List<int> data = json['data'] as List<int>;
    _data.setRange(0, length, data);
  }

  Map<String, dynamic> saveState() {
    assert(_isReadonly == false);

    return <String, dynamic>{
      'start': start,
      'length': length,
      'readOnly': _isReadonly,
      'data': List<int>.from(_data),
    };
  }

  MemoryChip clone() => MemoryChip._(
        start: start,
        length: length,
        isReadonly: _isReadonly,
        data: Uint8ClampedList.fromList(_data.toList()),
      );

  @override
  bool get isReadonly => _isReadonly;

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

  @override
  List<Object> get props =>
      <Object>[start, length, _isReadonly, _data, _observers];

  @override
  bool get stringify => true;
}
