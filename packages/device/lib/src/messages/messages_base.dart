import 'dart:typed_data';

/// Identifies the type of message exchanged between the UI and the emulator
/// isolate. The enum index is used as the first byte of each serialized
/// message.
enum EmulatorMessageId {
  // UI → Emulator.
  startEmulator,
  updateDeviceType,

  // Emulator → UI.
  isDebugClientConnected,
  lcdEvent,

  // UI → Emulator key events.
  keyDown,
  keyUp,

  // Debugger ↔ Emulator.
  step,
}

/// Base class for typed emulator messages.
abstract class EmulatorMessageBase {
  EmulatorMessageBase(this.messageId);

  final EmulatorMessageId messageId;
}

/// Base class for message serializers. Subclasses must implement both
/// [serialize] and [deserialize].
abstract class EmulatorMessageSerializer<T> {
  Uint8List serialize(T message);
  T deserialize(Uint8List data);

  /// Encodes a 16-bit integer as two bytes (big-endian).
  static Uint8List serializeInt(int value) {
    final int v = value & 0xFFFF;
    return Uint8List.fromList(<int>[v >> 8, v & 0xFF]);
  }

  /// Decodes a 16-bit integer from two bytes (big-endian).
  static int deserializeInt(Uint8List data) {
    assert(data.length >= 2);
    return data[0] << 8 | data[1];
  }
}
