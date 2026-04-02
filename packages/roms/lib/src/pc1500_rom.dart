import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:roms/src/pc1500_a03.dart' as pc1500_a03;
import 'package:roms/src/pc1500_a03_annotations.dart' as pc1500_a03_annotations;
import 'package:roms/src/rom_base.dart';

enum PC1500RomType { a01, a03, a04 }

final Map<PC1500RomType, List<int>> _roms = <PC1500RomType, List<int>>{
  PC1500RomType.a03: pc1500_a03.bytes,
};

final Map<PC1500RomType, String> _annotationsJson = <PC1500RomType, String>{
  PC1500RomType.a03: pc1500_a03_annotations.pc1500A03AnnotationsJson,
};

class PC1500Rom implements RomBase {
  PC1500Rom(this.type) {
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

  final PC1500RomType type;
  late final Uint8List _bytes;
  late final Digest _hash;
  Map<String, dynamic> _annotations = <String, dynamic>{};

  Map<String, dynamic> get annotations =>
      Map<String, dynamic>.unmodifiable(_annotations);

  @override
  Uint8List get bytes => Uint8List.fromList(_bytes);

  @override
  Digest get hash => _hash;

  static Iterable<PC1500RomType> get available => _roms.keys;
}
