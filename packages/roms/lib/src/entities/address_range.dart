import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class AddressRange extends Equatable {
  const AddressRange._({@required this.start, @required this.end});

  factory AddressRange.fromTag({@required String tag}) {
    assert(tag != null && tag.isNotEmpty && <int>[4, 9].contains(tag.length));

    int start, end;
    start = end = _parse(tag.substring(0, 4));
    if (tag.length == 9) {
      assert(tag[4] == '-');
      end = _parse(tag.substring(5, 9));
    }

    return AddressRange._(start: start, end: end);
  }

  final int start;
  final int end;

  bool contains(int value) => start <= value && value <= end;

  static int _parse(String str) {
    final int value = int.tryParse(str, radix: 16);
    assert(str != null);
    return value;
  }

  @override
  List<Object> get props => <Object>[start, end];

  @override
  bool get stringify => true;
}
