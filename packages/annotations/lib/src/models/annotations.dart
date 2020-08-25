import 'package:meta/meta.dart';

import 'models.dart';

@immutable
class Annotations {
  const Annotations._({@required this.areas});

  factory Annotations.fromJson(Map<String, dynamic> json) {
    final List<AnnotatedArea> areas = <AnnotatedArea>[];

    for (final String tag in json.keys) {
      assert(json[tag] != null);

      final AddressSpace addressSpace = AddressSpace.fromTag(tag);
      final AnnotatedArea area = AnnotatedArea.fromJson(
        null,
        addressSpace,
        json[tag] as Map<String, dynamic>,
      );

      areas.add(area);
    }

    return Annotations._(areas: areas);
  }

  final List<AnnotatedArea> areas;
}
