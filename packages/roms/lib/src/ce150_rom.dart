import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'ce150_version_1.dart' as ce150_version_1;
import 'ce150_version_1_annotations.dart' as ce150_version_1_annotations;
import 'rom_base.dart';

enum CE150RomType { version_0, version_1 }

final Map<CE150RomType, List<int>> _roms = <CE150RomType, List<int>>{
  CE150RomType.version_1: ce150_version_1.bytes,
};

final Map<CE150RomType, String> _annotationsJson = <CE150RomType, String>{
  CE150RomType.version_1: ce150_version_1_annotations.json,
};

class CE150Rom implements RomBase {
  CE150Rom(this.type) {
    if (_roms.containsKey(type) == false) {
      throw Exception('ROM not available');
    }

    _bytes = Uint8List.fromList(_roms[type]);

    if (_annotationsJson.containsKey(type)) {
      try {
        annotations =
            jsonDecode(_annotationsJson[type]) as Map<String, dynamic>;
      } catch (e) {
        annotations = <String, dynamic>{};
      }
    }
  }

  final CE150RomType type;
  Uint8List _bytes;
  Map<String, dynamic> annotations;

  @override
  Uint8List get bytes => Uint8List.view(_bytes.buffer);

  @override
  Digest get hash => sha1.convert(_bytes);

  static Iterable<CE150RomType> get available => _roms.keys;
}
