import 'dart:typed_data';

enum EmulatorMessageId {
  // UI -> Emulator messages.
  startEmulator,
  updateDeviceType,

  // Emulator -> UI messages.
  isDebugClientConnected,
  lcdEvent,

  // Debugger <-> emulator messages.
  step,
}

abstract class EmulatorMessageBase {
  EmulatorMessageBase(this.messageId) : assert(messageId != null);

  final EmulatorMessageId messageId;
}

abstract class EmulatorMessageSerializer<T> {
  Uint8List serialize(T _) => throw UnimplementedError();

  T deserialize(Uint8List _) => throw UnimplementedError();

  Uint8List serializeInt(int value) {
    final int value16 = value & 0xFFFF; // 16-bit integers.
    return Uint8List.fromList(<int>[value16 >> 8, value16 & 0xFF]);
  }

  int deserializeInt(Uint8List data) {
    assert(data.length >= 2); // 16-bit integers.
    return data[0] << 8 | data[1];
  }
}

extension IntEmulatorMessageSerializer on int {
  Uint8List toUint8List() {
    final int value = this & 0xFFFF; // 16-bit integers.
    return Uint8List.fromList(<int>[value >> 8, value & 0xFF]);
  }

  Uint8List toEmulatorMessage(EmulatorMessageId id) {
    final int value = this & 0xFFFF; // 16-bit integers.
    return Uint8List.fromList(<int>[id.index, value >> 8, value & 0xFF]);
  }
}
