import 'package:chip_select_decoder/chip_select_decoder.dart';
import 'package:meta/meta.dart';

typedef MemoryRead = int Function(int address);

class Lcd with MemoryObserver {
  Lcd({@required MemoryRead memRead})
      : assert(memRead != null),
        _memRead = memRead;

  final MemoryRead _memRead;

  @override
  void update(MemoryAccessType type, int address, int value) {}
}
