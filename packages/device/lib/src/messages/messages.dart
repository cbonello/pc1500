import 'dart:typed_data';

import 'package:lcd/lcd.dart';
import 'package:meta/meta.dart';

import '../device.dart';
import 'messages_base.dart';

class StartEmulatorMessage extends EmulatorMessageBase {
  StartEmulatorMessage({@required this.type, @required this.debugPort})
      : assert(type != null),
        super(EmulatorMessageId.startEmulator);

  final DeviceType type;
  final int debugPort;
}

class StartEmulatorMessageSerializer
    extends EmulatorMessageSerializer<StartEmulatorMessage> {
  @override
  StartEmulatorMessage deserialize(Uint8List data) {
    assert(data.length == 3);
    assert(data[0] == EmulatorMessageId.startEmulator.index);

    return StartEmulatorMessage(
      type: DeviceType.values[data[1]],
      debugPort: data[2],
    );
  }

  @override
  Uint8List serialize(StartEmulatorMessage le) =>
      le.debugPort.toUint8List(le.messageId);
}

class SetDeviceTypeMessage extends EmulatorMessageBase {
  SetDeviceTypeMessage({@required this.type})
      : assert(type != null),
        super(EmulatorMessageId.updateDeviceType);

  final DeviceType type;
}

class SetDeviceTypeMessageSerializer
    extends EmulatorMessageSerializer<SetDeviceTypeMessage> {
  @override
  SetDeviceTypeMessage deserialize(Uint8List data) {
    assert(data.length == 2);
    assert(data[0] == EmulatorMessageId.updateDeviceType.index);

    return SetDeviceTypeMessage(type: DeviceType.values[data[1]]);
  }

  @override
  Uint8List serialize(SetDeviceTypeMessage sdt) =>
      sdt.type.index.toUint8List(sdt.messageId);
}

class SetDebugPortMessage extends EmulatorMessageBase {
  SetDebugPortMessage({@required this.port})
      : assert(port != null && port >= 0 && port < 65536),
        super(EmulatorMessageId.setDebutPort);

  final int port;
}

class SetDebugPortMessageSerializer
    extends EmulatorMessageSerializer<SetDebugPortMessage> {
  @override
  SetDebugPortMessage deserialize(Uint8List data) {
    assert(data.length == 2);
    assert(data[0] == EmulatorMessageId.setDebutPort.index);

    return SetDebugPortMessage(port: data[1]);
  }

  @override
  Uint8List serialize(SetDebugPortMessage sdp) =>
      Uint8List.fromList(<int>[sdp.messageId.index, sdp.port]);
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
