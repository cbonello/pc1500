import 'package:meta/meta.dart';

import 'address_range.dart';

abstract class AnnotationBase {
  const AnnotationBase({@required this.range}) : assert(range != null);

  final AddressRange range;
}

@immutable
class Area extends AnnotationBase {
  const Area({@required AddressRange range, @required this.name})
      : assert(range != null),
        super(range: range);

  final String name;
}

@immutable
class Section extends AnnotationBase {
  const Section({@required AddressRange range, @required this.name})
      : assert(range != null),
        super(range: range);

  final String name;
}

@immutable
class CodeAnnotation extends AnnotationBase {
  const CodeAnnotation._({
    @required this.section,
    @required AddressRange range,
    this.label,
    this.comment,
  })  : assert(section != null),
        assert(range != null),
        assert(label != null || comment != null),
        super(range: range);

  factory CodeAnnotation.fromJson(
    Section section,
    AddressRange range,
    Map<String, dynamic> json,
  ) {
    assert(range.length == 1);
    assert(section.range.containsAddress(range.start));

    return CodeAnnotation._(
      section: section,
      range: range,
      label: json['label'] as String,
      comment: json['comment'] as String,
    );
  }

  final Section section;
  final String label;
  final String comment;
}

@immutable
class DataAnnotation extends AnnotationBase {
  const DataAnnotation._({
    @required this.section,
    @required AddressRange range,
    this.label,
    @required this.comment,
    this.type,
  })  : assert(section != null),
        assert(range != null),
        assert(comment != null),
        super(range: range);

  factory DataAnnotation.fromJson(
    Section section,
    AddressRange range,
    Map<String, dynamic> json,
  ) {
    assert(section.range.containsRange(range));
    final String type = json['type'] as String;
    assert(
      type == null || DataAnnotation._validTypes.contains(type),
    );

    return DataAnnotation._(
      section: section,
      range: range,
      label: json['label'] as String,
      comment: json['comment'] as String,
      type: type,
    );
  }

  final Section section;
  final String label;
  final String comment;
  final String type;

  static const List<String> _validTypes = <String>[
    'fixed_char_var',
    'fixed_num_var',
    'arith_reg',
  ];
}
