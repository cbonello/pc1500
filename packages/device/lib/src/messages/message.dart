import 'dart:typed_data';

import 'package:meta/meta.dart';

enum MessageId { startEmulator, setDeviceType, setDebutPort, lcdEvent }

abstract class Message {
  Message({@required this.messageId}) : assert(messageId != null);

  final MessageId messageId;
}

abstract class MessageSerializer<T> {
  Uint8List serialize(T _) => throw UnimplementedError();

  T deserialize(Uint8List _) => throw UnimplementedError();
}
