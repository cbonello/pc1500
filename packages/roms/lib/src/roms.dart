import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'a03.dart' as a03;

part 'roms.freezed.dart';

@freezed
abstract class ROMType with _$ROMType {
  const factory ROMType.a01() = _A01;
  const factory ROMType.a03() = _A03;
  const factory ROMType.a04() = _A04;
}

final Map<ROMType, List<int>> _roms = <ROMType, List<int>>{
  const ROMType.a03(): a03.bytes,
};

class ROM {
  ROM(this.type) {
    if (_roms.containsKey(type) == false) {
      throw Exception('ROM not available');
    }
    _bytes = Uint8List.fromList(_roms[type]);
  }

  final ROMType type;
  Uint8List _bytes;

  Uint8List get bytes => Uint8List.view(_bytes.buffer);

  static Iterable<ROMType> get available => _roms.keys;
}
