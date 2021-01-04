import 'dart:typed_data';

import 'package:lcd/lcd.dart';
import 'package:meta/meta.dart';

import '../device.dart';
import 'messages_base.dart';

class StartEmulatorMessage extends EmulatorMessageBase {
  StartEmulatorMessage({@required this.type, @required this.debugPort})
      : assert(type != null),
        super(EmulatorMessageId.startEmulator);

  final HardwareDeviceType type;
  final int debugPort;
}

class StartEmulatorMessageSerializer
    extends EmulatorMessageSerializer<StartEmulatorMessage> {
  @override
  StartEmulatorMessage deserialize(Uint8List data) {
    assert(data.length == 4);
    assert(data[0] == EmulatorMessageId.startEmulator.index);

    return StartEmulatorMessage(
      type: HardwareDeviceType.values[data[1]],
      debugPort: deserializeInt(data.sublist(2)),
    );
  }

  @override
  Uint8List serialize(StartEmulatorMessage le) => Uint8List.fromList(
        <int>[
          le.messageId.index,
          le.type.index,
          ...serializeInt(le.debugPort),
        ],
      );
}

class UpdateDeviceTypeMessage extends EmulatorMessageBase {
  UpdateDeviceTypeMessage({@required this.type})
      : assert(type != null),
        super(EmulatorMessageId.updateDeviceType);

  final HardwareDeviceType type;
}

class UpdateDeviceTypeMessageSerializer
    extends EmulatorMessageSerializer<UpdateDeviceTypeMessage> {
  @override
  UpdateDeviceTypeMessage deserialize(Uint8List data) {
    assert(data.length == 2);
    assert(data[0] == EmulatorMessageId.updateDeviceType.index);

    return UpdateDeviceTypeMessage(type: HardwareDeviceType.values[data[1]]);
  }

  @override
  Uint8List serialize(UpdateDeviceTypeMessage sdt) =>
      sdt.type.index.toEmulatorMessage(sdt.messageId);
}

class LcdEventSerializer extends EmulatorMessageSerializer<LcdEvent> {
  @override
  LcdEvent deserialize(Uint8List data) {
    assert(data.length == 1 + LcdEvent.length);
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

    return LcdEvent(
      displayBuffer1: displayBuffer1,
      displayBuffer2: displayBuffer2,
      symbols: symbols,
    );
  }

  @override
  Uint8List serialize(LcdEvent lcdEvent) => Uint8List.fromList(
        <int>[
          EmulatorMessageId.lcdEvent.index,
          ...lcdEvent.displayBuffer1,
          ...lcdEvent.displayBuffer2,
          ...lcdEvent.symbols.data,
        ],
      );
}

class IsDebugClientConnectedMessage extends EmulatorMessageBase {
  IsDebugClientConnectedMessage({@required this.status})
      : assert(status != null),
        super(EmulatorMessageId.isDebugClientConnected);

  final bool status;
}

class IsDebugClientConnectedMessageSerializer
    extends EmulatorMessageSerializer<IsDebugClientConnectedMessage> {
  @override
  IsDebugClientConnectedMessage deserialize(Uint8List data) {
    assert(data.length == 2);
    assert(data[0] == EmulatorMessageId.isDebugClientConnected.index);
    assert(<int>[0, 1].contains(data[1]));

    return IsDebugClientConnectedMessage(status: data[1] == 1);
  }

  @override
  Uint8List serialize(IsDebugClientConnectedMessage dc) =>
      Uint8List.fromList(<int>[
        dc.messageId.index,
        if (dc.status) 1 else 0,
      ]);
}
