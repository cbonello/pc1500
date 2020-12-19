import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../emulator_isolate/device.dart';
import 'message.dart';

class SetDeviceTypeMessage extends Message {
  SetDeviceTypeMessage({@required this.type})
      : assert(type != null),
        super(messageId: MessageId.setDeviceType);

  final DeviceType type;
}

class SetDeviceTypeMessageSerializer
    extends MessageSerializer<SetDeviceTypeMessage> {
  @override
  SetDeviceTypeMessage deserialize(Uint8List data) {
    assert(data.length == 2);
    assert(data[0] == MessageId.setDeviceType.index);

    return SetDeviceTypeMessage(type: DeviceType.values[data[1]]);
  }

  @override
  Uint8List serialize(SetDeviceTypeMessage sdt) =>
      Uint8List.fromList(<int>[sdt.messageId.index, sdt.type.index]);
}

class SetDebugPortMessage extends Message {
  SetDebugPortMessage({@required this.port})
      : assert(port != null && port >= 0 && port < 65536),
        super(messageId: MessageId.setDebutPort);

  final int port;
}

class SetDebugPortMessageSerializer
    extends MessageSerializer<SetDebugPortMessage> {
  @override
  SetDebugPortMessage deserialize(Uint8List data) {
    assert(data.length == 2);
    assert(data[0] == MessageId.setDebutPort.index);

    return SetDebugPortMessage(port: data[1]);
  }

  @override
  Uint8List serialize(SetDebugPortMessage sdp) =>
      Uint8List.fromList(<int>[sdp.messageId.index, sdp.port]);
}
