import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class MemoryError extends Error {
  MemoryError(this.message);

  final String message;

  @override
  String toString() => 'Memory Error: $message';
}

mixin MemoryBase {
  bool get isReadonly => throw UnimplementedError;
  int readByteAt(int offsetInBytes) => throw UnimplementedError;
  void writeByteAt(int offsetInBytes, int value) => throw UnimplementedError;
}

class Memory extends Equatable with MemoryBase {
  const Memory._({Uint8ClampedList data, bool readOnly})
      : _data = data,
        _readOnly = readOnly;

  factory Memory.ram(int size) {
    if (size < 1) {
      throw ArgumentError.value(size, 'size', 'RAM size must be greater than zero');
    }
    return Memory._(data: Uint8ClampedList(size), readOnly: false);
  }

  factory Memory.rom(Uint8List content) {
    if (content == null) {
      throw ArgumentError.notNull('content');
    }
    if (content.isEmpty) {
      throw ArgumentError.value(content, 'content', 'cannot be empty');
    }
    return Memory._(data: Uint8ClampedList.fromList(content), readOnly: true);
  }

  final Uint8ClampedList _data;

  // True if ROM, otherwise false if RAM.
  final bool _readOnly;

  void restoreState(Map<String, dynamic> json) {
    final bool isRam = json['isRam'] as bool;
    final List<int> data = json['data'] as List<int>;

    // ROMs are immutable (and read-only!)
    if (isRam) {
      write(0, Uint8List.fromList(data));
    }
  }

  Map<String, dynamic> saveState() => <String, dynamic>{
        'isRam': isReadonly == false,
        'length': length,
        'data': List<int>.from(read()),
      };

  int get length => _data.length;

  @override
  bool get isReadonly => _readOnly;

  UnmodifiableUint8ClampedListView read([int offsetInBytes = 0, int length]) =>
      UnmodifiableUint8ClampedListView(
        Uint8ClampedList.view(
          _data.buffer,
          offsetInBytes,
          length,
        ),
      );

  @override
  int readByteAt(int offsetInBytes) {
    if (offsetInBytes < 0 || offsetInBytes >= length) {
      throw RangeError.index(offsetInBytes, _data);
    }
    return _data[offsetInBytes];
  }

  void write(int offsetInBytes, Uint8List data) {
    _checkIfWritable();
    _data.setRange(offsetInBytes, offsetInBytes + data.length, data);
  }

  @override
  void writeByteAt(int offsetInBytes, int value) {
    _checkIfWritable();
    _data[offsetInBytes] = value;
  }

  Memory clone() => Memory._(
        data: Uint8ClampedList.fromList(_data.toList()),
        readOnly: _readOnly,
      );

  void _checkIfWritable() {
    if (isReadonly == true) {
      throw MemoryError('writeByteAt: could not write to ROM');
    }
  }

  @override
  List<Object> get props => <Object>[_readOnly, _data];

  @override
  bool get stringify => true;
}
