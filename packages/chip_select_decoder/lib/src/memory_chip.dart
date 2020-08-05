import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'memory.dart';

abstract class WriteObserver {
  void checkWrite(int address, int value);
}

class MemoryChip extends Equatable with MemoryBase {
  const MemoryChip({
    @required this.start,
    @required this.end,
    @required Memory memory,
    WriteObserver observer,
  })  : assert(memory != null),
        _memory = memory,
        _observer = observer;

  final int start;
  final int end;
  final Memory _memory;
  final WriteObserver _observer;

  void restoreState(Map<String, dynamic> json) =>
      _memory.restoreState(json['memory'] as Map<String, dynamic>);

  Map<String, dynamic> saveState() => <String, dynamic>{
        'start': start,
        'end': end,
        'memory': _memory.saveState(),
      };

  MemoryChip clone() => MemoryChip(
        start: start,
        end: end,
        memory: _memory.clone(),
        observer: _observer,
      );

  @override
  bool get isReadonly => _memory.isReadonly;

  @override
  int readByteAt(int offsetInBytes) => _memory.readByteAt(offsetInBytes);

  @override
  void writeByteAt(int offsetInBytes, int value) {
    _memory.writeByteAt(offsetInBytes, value);
    _observer?.checkWrite(offsetInBytes, value);
  }

  @override
  List<Object> get props => <Object>[start, end, _memory, _observer];

  @override
  bool get stringify => true;
}
