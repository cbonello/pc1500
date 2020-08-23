import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class AddressRange extends Equatable {
  const AddressRange._({
    @required this.tag,
    @required this.start,
    @required this.end,
  }) : assert(start <= end);

  factory AddressRange.fromTag(String tag) {
    assert(tag != null && tag.isNotEmpty);

    int start, end;
    switch (tag.length) {
      case 4:
        start = end = _parse(tag.substring(0, 4));
        break;
      case 5:
        assert(tag[0] == '#');
        start = end = 0x1000 | _parse(tag.substring(1, 5));
        break;
      case 9:
        assert(tag[4] == '-');
        start = _parse(tag.substring(0, 4));
        end = _parse(tag.substring(5, 9));
        break;
      case 11:
        assert(tag[4] == '-' && tag[5] == '#');
        start = 0x1000 | _parse(tag.substring(1, 5));
        end = 0x1000 | _parse(tag.substring(7, 11));
        break;
      default:
        assert(false, 'Invalid address range');
    }

    return AddressRange._(tag: tag, start: start, end: end);
  }

  final String tag;
  final int start;
  final int end;

  int get length => end - start + 1;

  bool containsAddress(int address) => start <= address && address <= end;

  bool containsRange(AddressRange range) =>
      start <= range.start &&
      range.start <= end &&
      start <= range.end &&
      range.end <= end;

  static int _parse(String str) {
    final int value = int.tryParse(str, radix: 16);
    assert(value != null);
    return value;
  }

  @override
  List<Object> get props => <Object>[start, end];

  @override
  bool get stringify => true;
}
