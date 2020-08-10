import 'dart:typed_data';

import 'sys1500.dart' as pc1500_rom;
import 'sys1500a.dart' as pc1500a_rom;

class Roms {
  static Uint8List get pc1500 => Uint8List.fromList(pc1500_rom.data);
  static Uint8List get pc1500a => Uint8List.fromList(pc1500a_rom.data);
}
