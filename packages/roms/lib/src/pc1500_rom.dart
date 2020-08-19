import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'entities/entities.dart';
import 'pc1500_a03.dart' as pc1500_a03;
import 'pc1500_a03_annotations.dart' as pc1500_a03_annotations;
import 'rom_base.dart';

enum PC1500RomType { a01, a03, a04 }

final Map<PC1500RomType, List<int>> _roms = <PC1500RomType, List<int>>{
  PC1500RomType.a03: pc1500_a03.bytes,
};

final Map<PC1500RomType, String> _annotationsJson = <PC1500RomType, String>{
  PC1500RomType.a03: pc1500_a03_annotations.json,
};

class PC1500Rom implements RomBase {
  PC1500Rom(this.type) {
    if (_roms.containsKey(type) == false) {
      throw Exception('ROM not available');
    }

    _bytes = Uint8List.fromList(_roms[type]);

    if (_annotationsJson.containsKey(type)) {
      try {
        final dynamic json = jsonDecode(_annotationsJson[type]);
        annotations = Annotations.fromJson(json as Map<String, dynamic>);
      } catch (e) {
        annotations = Annotations.empty();
      }
    }
  }

  final PC1500RomType type;
  Uint8List _bytes;
  Annotations annotations;

  @override
  Uint8List get bytes => Uint8List.view(_bytes.buffer);

  @override
  Digest get hash => sha1.convert(_bytes);

  static Iterable<PC1500RomType> get available => _roms.keys;
}
