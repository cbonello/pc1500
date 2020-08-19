import 'dart:typed_data';

import 'package:crypto/crypto.dart';

abstract class RomBase {
  Uint8List get bytes;
  Digest get hash;
}
