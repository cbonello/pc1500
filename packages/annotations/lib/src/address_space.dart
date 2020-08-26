import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class AddressSpace extends Equatable with IterableMixin<int> {
  const AddressSpace._({
    @required this.tag,
    @required this.start,
    @required this.end,
  }) : assert(start <= end);

  factory AddressSpace.fromTag(String tag) {
    assert(tag != null && tag.isNotEmpty);

    int start, end;
    switch (tag.length) {
      case 4:
        start = end = _parse(tag.substring(0, 4));
        break;
      case 5:
        assert(tag[0] == '#');
        start = end = 0x10000 | _parse(tag.substring(1, 5));
        break;
      case 9:
        assert(tag[4] == '-');
        start = _parse(tag.substring(0, 4));
        end = _parse(tag.substring(5, 9));
        break;
      case 11:
        assert(tag[0] == '#' && tag[5] == '-' && tag[6] == '#');
        start = 0x10000 | _parse(tag.substring(1, 5));
        end = 0x10000 | _parse(tag.substring(7, 11));
        break;
      default:
        assert(false, 'Invalid address-space [$tag]');
    }

    return AddressSpace._(tag: tag, start: start, end: end);
  }

  final String tag;
  final int start;
  final int end;

  @override
  int get length => end - start + 1;

  @override
  Iterator<int> get iterator => _AddressSpaceIterator(start: start, end: end);

  int get memoryBank => start < 0x10000 ? 0 : 1;

  bool containsAddress(int address) => start <= address && address <= end;

  bool containsAddressSpace(AddressSpace addressSpace) =>
      start <= addressSpace.start &&
      addressSpace.start <= end &&
      start <= addressSpace.end &&
      addressSpace.end <= end;

  bool intersectWith(AddressSpace addressSpace) =>
      (start <= addressSpace.start && addressSpace.start <= end) ||
      (start <= addressSpace.end && addressSpace.end <= end) ||
      (addressSpace.start <= start && addressSpace.end >= end);

  static int _parse(String str) {
    final int value = int.tryParse(str, radix: 16);
    assert(value != null);
    return value;
  }

  @override
  List<Object> get props => <Object>[tag, start, end];

  @override
  String toString() => '[$tag]';
}

class _AddressSpaceIterator implements Iterator<int> {
  _AddressSpaceIterator({@required this.start, @required this.end})
      : assert(start <= end),
        _current = start - 1;

  final int start;
  final int end;
  int _current;

  @override
  int get current => _current;

  @override
  bool moveNext() {
    if (_current < end) {
      _current++;
      return true;
    }
    return false;
  }
}
