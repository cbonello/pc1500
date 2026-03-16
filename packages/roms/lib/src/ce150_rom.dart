import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:roms/src/ce150_version_1.dart' as ce150_version_1;
import 'package:roms/src/ce150_version_1_annotations.dart'
    as ce150_version_1_annotations;
import 'package:roms/src/rom_base.dart';

enum CE150RomType { version_0, version_1 }

final Map<CE150RomType, List<int>> _roms = <CE150RomType, List<int>>{
  CE150RomType.version_1: ce150_version_1.bytes,
};

final Map<CE150RomType, String> _annotationsJson = <CE150RomType, String>{
  CE150RomType.version_1: ce150_version_1_annotations.json,
};

class CE150Rom implements RomBase {
  CE150Rom(this.type) {
    final List<int>? rom = _roms[type];
    if (rom == null) {
      throw Exception('ROM not available');
    }

    _bytes = Uint8List.fromList(rom);

    final String? annotationsStr = _annotationsJson[type];
    if (annotationsStr != null) {
      try {
        _annotations =
            jsonDecode(annotationsStr) as Map<String, dynamic>;
      } catch (_) {
        _annotations = <String, dynamic>{};
      }
    }
  }

  final CE150RomType type;
  late final Uint8List _bytes;
  Map<String, dynamic> _annotations = <String, dynamic>{};

  Map<String, dynamic> get annotations => _annotations;

  @override
  Uint8List get bytes => Uint8List.view(_bytes.buffer);

  @override
  Digest get hash => sha1.convert(_bytes);

  static Iterable<CE150RomType> get available => _roms.keys;
}
