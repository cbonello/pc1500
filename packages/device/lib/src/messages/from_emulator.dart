import 'dart:typed_data';

import 'package:lcd/lcd.dart';
import 'package:meta/meta.dart';

import 'message.dart';

class LcdEventMessage extends Message {
  LcdEventMessage({@required this.event})
      : assert(event != null),
        super(messageId: MessageId.lcdEvent);

  final LcdEvent event;
}

class LcdEventMessageSerializer extends MessageSerializer<LcdEventMessage> {
  @override
  LcdEventMessage deserialize(Uint8List data) {
    assert(data.length == 1 + LcdEvent.length);
    assert(data[0] == MessageId.lcdEvent.index);

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

    return LcdEventMessage(
      event: LcdEvent(
        displayBuffer1: displayBuffer1,
        displayBuffer2: displayBuffer2,
        symbols: symbols,
      ),
    );
  }

  @override
  Uint8List serialize(LcdEventMessage lcdEvent) => Uint8List.fromList(
        <int>[
          lcdEvent.messageId.index,
          ...lcdEvent.event.displayBuffer1,
          ...lcdEvent.event.displayBuffer2,
          ...lcdEvent.event.symbols.data,
        ],
      );
}
