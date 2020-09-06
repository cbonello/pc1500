import 'package:chip_select_decoder/chip_select_decoder.dart';

void main() {
  final ChipSelectDecoder csd = ChipSelectDecoder();
  final MemoryChipBase ram = csd.appendRAM(
    MemoryBank.me0,
    0x7600,
    0x0600,
  );

  final int before = csd.readByteAt(0x7600);
  csd.writeByteAt(0x7600, 0xFF);
  final int after = csd.readByteAt(0x7600);
  print('Value before: $before - Value after: $after');

  // Write to unmapped memory.
  try {
    csd.writeByteAt(0x0000, 0xFF);
  } catch (e) {
    print('error: ${e.message}');
  }
}
