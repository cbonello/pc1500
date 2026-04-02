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
  CE150RomType.version_1: ce150_version_1_annotations.ce150Version1AnnotationsJson,
};

class CE150Rom implements RomBase {
  CE150Rom(this.type) {
    final List<int>? rom = _roms[type];
    if (rom == null) {
      throw Exception('ROM not available');
    }

    _bytes = Uint8List.fromList(rom);
    _hash = sha1.convert(_bytes);

    final String? annotationsStr = _annotationsJson[type];
    if (annotationsStr != null) {
      _annotations = jsonDecode(annotationsStr) as Map<String, dynamic>;
    }
  }

  final CE150RomType type;
  late final Uint8List _bytes;
  late final Digest _hash;
  Map<String, dynamic> _annotations = <String, dynamic>{};

  Map<String, dynamic> get annotations =>
      Map<String, dynamic>.unmodifiable(_annotations);

  @override
  Uint8List get bytes => Uint8List.fromList(_bytes);

  @override
  Digest get hash => _hash;

  static Iterable<CE150RomType> get available => _roms.keys;
}
