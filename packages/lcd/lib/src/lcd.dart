import 'package:chip_select_decoder/chip_select_decoder.dart';

typedef MemoryRead = int Function(int address);

class Lcd with MemoryObserver {
  Lcd({this.memRead});

  final MemoryRead memRead;

  @override
  void update(MemoryAccessType type, int address, int value) {}
}
