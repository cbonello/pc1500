import 'package:meta/meta.dart';

import 'entities.dart';

@immutable
class Annotations {
  const Annotations._({@required Map<AddressRange, Annotation> annotations})
      : assert(annotations != null),
        _annotations = annotations;

  factory Annotations.empty() =>
      const Annotations._(annotations: <AddressRange, Annotation>{});

  factory Annotations.fromJson(Map<String, dynamic> json) {
    final Map<AddressRange, Annotation> annotations =
        <AddressRange, Annotation>{};

    for (final String tag in json.keys) {
      final AddressRange range = AddressRange.fromTag(tag: tag);
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
