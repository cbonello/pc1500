import 'package:meta/meta.dart';

import 'address_range.dart';

@immutable
class Annotations {
  factory Annotations() => const Annotations._(
        annotations: <int, Annotation>{},
        sections: <AddressRange, Section>{},
      );

  factory Annotations.fromJson(Map<String, dynamic> json) {
    final Map<AddressRange, Annotation> annotations =
        <AddressRange, Annotation>{};

    for (final String tag in json.keys) {
      final AddressRange range = AddressRange.fromTag(tag);
      final Annotation annotation = Annotation.fromJson(
        json[tag] as Map<String, dynamic>,
      );

      annotations[range] = annotation;
    }

    return Annotations._(annotations: annotations);
  }

  // const Annotations._({
  //   @required Map<int, Annotation> annotations,
  //   @required Map<AddressRange, Section> sections,
  // })  : _annotations = annotations,
  //       _sections = sections;

  // Map<MemoryBank, > _a;

  // final Map<AddressRange, Section> _sections;
  // final Map<int, Annotation> _annotations;

  // void _addAnnotation(AddressRange range, Annotation annotation) {
  //   _annotations[range.start] = annotation;
  // }

  // Annotation find(int address) {}
}

enum SectionType { ram, rom }

@immutable
class Section {
  const Section({
    @required this.range,
    @required this.name,
    @required this.type,
  })  : assert(range != null),
        assert(name != null),
        assert(type != null);

  final AddressRange range;
  final String name;
  final SectionType type;
}

enum AnnotationType { code, data, graphic }

@immutable
class Annotation {
  const Annotation({
    @required this.section,
    @required this.type,
    this.name,
    @required this.comment,
  })  : assert(section != null),
        assert(type != null),
        assert(comment != null);

  final Section section;
  final AnnotationType type;
  final String name;
  final String comment;
}

/*
  const Annotations._({@required Map<AddressRange, Annotation> annotations})
      : assert(annotations != null),
        _annotations = annotations;

  factory Annotations.empty() =>
      const Annotations._(annotations: <AddressRange, Annotation>{});

  factory Annotations.fromJson(Map<String, dynamic> json) {
    final Map<AddressRange, Annotation> annotations =
        <AddressRange, Annotation>{};

    for (final String tag in json.keys) {
      final AddressRange range = AddressRange.fromTag(tag);
      final Annotation annotation = Annotation.fromJson(
        json[tag] as Map<String, dynamic>,
      );

      annotations[range] = annotation;
    }

    return Annotations._(annotations: annotations);
  }

  final Map<AddressRange, Annotation> _annotations;

  int get length => _annotations.keys.length;

  Annotation find(int address) {
    final AddressRange range = _annotations.keys.firstWhere(
      (AddressRange range) => range.contains(address),
      orElse: () => null,
    );

    if (range != null) {
      return _annotations[range];
    }

    return null;
  }
}

@immutable
class Annotation {
  const Annotation._({@required this.comment, this.tag});

  factory Annotation.fromJson(Map<String, dynamic> json) {
    assert(json.keys.contains('comment'));

    final String tag = json['tag'] as String;

    return Annotation._(
      comment: json['comment'] as String,
      tag: tag ?? '',
    );
  }

  final String comment;
  final String tag;

  @override
  String toString() => 'comment: "$comment", tag: $tag';
}
*/
