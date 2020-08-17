import 'package:lh5801/lh5801.dart';
import 'package:system/system.dart';

void main() {
  final PC1500 system = PC1500(DeviceType.pc2);
  int address = 0xE000;

  for (int i = 0; i < 500; i++) {
    final Instruction instruction = system.dasm(address);
    print(instruction);
    address += instruction.descriptor.size;
  }
}
