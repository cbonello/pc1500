import 'dart:typed_data';

enum EmulatorMessageId {
  startEmulator,
  updateDeviceType,
  setDebutPort,
  lcdEvent
}

abstract class EmulatorMessageBase {
  EmulatorMessageBase(this.messageId) : assert(messageId != null);

  final EmulatorMessageId messageId;
}

abstract class EmulatorMessageSerializer<T> {
  Uint8List serialize(T _) => throw UnimplementedError();

  T deserialize(Uint8List _) => throw UnimplementedError();
}

extension IntEmulatorMessageSerializer on int {
  Uint8List toUint8List(EmulatorMessageId id) =>
      Uint8List.fromList(<int>[id.index, this]);
}
