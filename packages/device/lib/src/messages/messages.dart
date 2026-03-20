import 'dart:typed_data';

import 'package:device/src/device.dart';
import 'package:device/src/messages/messages_base.dart';
import 'package:lcd/lcd.dart';

/// Sent by the UI to create and configure the emulator.
class StartEmulatorMessage extends EmulatorMessageBase {
  StartEmulatorMessage({required this.type, required this.debugPort})
    : super(EmulatorMessageId.startEmulator);

  final HardwareDeviceType type;
  final int debugPort;
}

/// Serializer for [StartEmulatorMessage].
///
/// Wire format: `[messageId, type_index, debugPort_hi, debugPort_lo]`.
class StartEmulatorMessageSerializer
    extends EmulatorMessageSerializer<StartEmulatorMessage> {
  @override
  StartEmulatorMessage deserialize(Uint8List data) {
    assert(data.length >= 4);
    assert(data[0] == EmulatorMessageId.startEmulator.index);

    return StartEmulatorMessage(
      type: HardwareDeviceType.values[data[1]],
      debugPort: EmulatorMessageSerializer.deserializeInt(data.sublist(2)),
    );
  }

  @override
  Uint8List serialize(StartEmulatorMessage msg) => Uint8List.fromList(<int>[
    msg.messageId.index,
    msg.type.index,
    ...EmulatorMessageSerializer.serializeInt(msg.debugPort),
  ]);
}

/// Sent by the UI to change the emulated hardware model.
class UpdateDeviceTypeMessage extends EmulatorMessageBase {
  UpdateDeviceTypeMessage({required this.type})
    : super(EmulatorMessageId.updateDeviceType);

  final HardwareDeviceType type;
}

/// Serializer for [UpdateDeviceTypeMessage].
///
/// Wire format: `[messageId, type_index]`.
class UpdateDeviceTypeMessageSerializer
    extends EmulatorMessageSerializer<UpdateDeviceTypeMessage> {
  @override
  UpdateDeviceTypeMessage deserialize(Uint8List data) {
    assert(data.length >= 2);
    assert(data[0] == EmulatorMessageId.updateDeviceType.index);

    return UpdateDeviceTypeMessage(type: HardwareDeviceType.values[data[1]]);
  }

  @override
  Uint8List serialize(UpdateDeviceTypeMessage msg) =>
      Uint8List.fromList(<int>[msg.messageId.index, msg.type.index]);
}

/// Serializer for [LcdEvent] (emulator → UI).
///
/// Wire format: `[messageId, buf1..., buf2..., sym0, sym1, displayOn]`.
class LcdEventSerializer extends EmulatorMessageSerializer<LcdEvent> {
  @override
  LcdEvent deserialize(Uint8List data) {
    assert(data.length >= 1 + LcdEvent.length);
    assert(data[0] == EmulatorMessageId.lcdEvent.index);

    int start = 1;
    final Uint8ClampedList displayBuffer1 = Uint8ClampedList.fromList(
      data.sublist(start, start + LcdEvent.displayBufferLength),
    );
    start += LcdEvent.displayBufferLength;
    final Uint8ClampedList displayBuffer2 = Uint8ClampedList.fromList(
      data.sublist(start, start + LcdEvent.displayBufferLength),
    );
    start += LcdEvent.displayBufferLength;
    final Uint8ClampedList symbolsBuffer = Uint8ClampedList.fromList(
      data.sublist(start, start + LcdEvent.symbolsLength),
    );
    final LcdSymbols symbols = LcdSymbols(data: symbolsBuffer);
    start += LcdEvent.symbolsLength;
    final bool displayOn = data[start] != 0;

    return LcdEvent(
      displayBuffer1: displayBuffer1,
      displayBuffer2: displayBuffer2,
      symbols: symbols,
      displayOn: displayOn,
    );
  }

  @override
  Uint8List serialize(LcdEvent lcdEvent) => Uint8List.fromList(<int>[
    EmulatorMessageId.lcdEvent.index,
    ...lcdEvent.displayBuffer1,
    ...lcdEvent.displayBuffer2,
    ...lcdEvent.symbols.data,
    if (lcdEvent.displayOn) 1 else 0,
  ]);
}

/// Sent by the emulator to notify the UI of debug client connection changes.
class IsDebugClientConnectedMessage extends EmulatorMessageBase {
  IsDebugClientConnectedMessage({required this.status})
    : super(EmulatorMessageId.isDebugClientConnected);

  final bool status;
}

/// Serializer for [IsDebugClientConnectedMessage].
///
/// Wire format: `[messageId, 0|1]`.
class IsDebugClientConnectedMessageSerializer
    extends EmulatorMessageSerializer<IsDebugClientConnectedMessage> {
  @override
  IsDebugClientConnectedMessage deserialize(Uint8List data) {
    assert(data.length >= 2);
    assert(data[0] == EmulatorMessageId.isDebugClientConnected.index);

    return IsDebugClientConnectedMessage(status: data[1] == 1);
  }

  @override
  Uint8List serialize(IsDebugClientConnectedMessage msg) =>
      Uint8List.fromList(<int>[msg.messageId.index, if (msg.status) 1 else 0]);
}

/// Sent by the UI when a key is pressed or released.
class KeyEventMessage extends EmulatorMessageBase {
  KeyEventMessage({required this.keyName, required bool isDown})
    : super(isDown ? EmulatorMessageId.keyDown : EmulatorMessageId.keyUp);

  final String keyName;
}

/// Serializer for [KeyEventMessage].
///
/// Wire format: `[messageId, ...keyName_codeUnits]`.
class KeyEventMessageSerializer
    extends EmulatorMessageSerializer<KeyEventMessage> {
  @override
  KeyEventMessage deserialize(Uint8List data) {
    final bool isDown = data[0] == EmulatorMessageId.keyDown.index;
    final String keyName = String.fromCharCodes(data.sublist(1));
    return KeyEventMessage(keyName: keyName, isDown: isDown);
  }

  @override
  Uint8List serialize(KeyEventMessage msg) =>
      Uint8List.fromList(<int>[msg.messageId.index, ...msg.keyName.codeUnits]);
}
