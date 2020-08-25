import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'models.dart';

class AnnotatedArea extends AnnotationBase with EquatableMixin {
  const AnnotatedArea._({
    this.parent,
    @required AddressSpace addressSpace,
    @required this.name,
    @required this.subAreas,
    @required this.codeAnnotations,
    @required this.dataAnnotations,
  })  : assert(addressSpace != null),
        assert(name != null),
        assert(subAreas != null),
        assert(codeAnnotations != null),
        assert(dataAnnotations != null),
        super(addressSpace: addressSpace);

  factory AnnotatedArea.empty({
    AnnotatedArea parent,
    @required AddressSpace addressSpace,
    @required String name,
  }) {
    assert(addressSpace != null);
    assert(name != null);

    return AnnotatedArea._(
      parent: parent,
      addressSpace: addressSpace,
      name: name,
      subAreas: <AnnotatedArea>[],
      codeAnnotations: <CodeAnnotation>[],
      dataAnnotations: <DataAnnotation>[],
    );
  }

  factory AnnotatedArea.fromJson(
    AnnotatedArea parent,
    AddressSpace addressSpace,
    Map<String, dynamic> json,
  ) {
    assert(parent?.addressSpace?.containsAddress(addressSpace.start) ?? true);

    final String name = json['name'] as String;
    assert(name != null, 'Missing area name @$addressSpace');

    final AnnotatedArea area = AnnotatedArea.empty(
      parent: parent,
      addressSpace: addressSpace,
      name: name,
    );

    final Map<String, dynamic> areas = json['areas'] as Map<String, dynamic>;
    if (areas != null) {
      for (final String tag in areas.keys) {
        assert(areas[tag] != null);

        final AddressSpace addrspace = AddressSpace.fromTag(tag);
        final AnnotatedArea subArea = AnnotatedArea.fromJson(
          area,
          addrspace,
          areas[tag] as Map<String, dynamic>,
        );
        area.subAreas.add(subArea);
      }
    }

    final Map<String, dynamic> code = json['code'] as Map<String, dynamic>;
    if (code != null) {
      for (final String tag in code.keys) {
        assert(code[tag] != null);

        final AddressSpace addrspace = AddressSpace.fromTag(tag);
        final CodeAnnotation codeAnnotation = CodeAnnotation.fromJson(
          area,
          addrspace,
          code[tag] as Map<String, dynamic>,
        );
        area.codeAnnotations.add(codeAnnotation);
      }
    }

    final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;
    if (data != null) {
      for (final String tag in data.keys) {
        assert(data[tag] != null);

        final AddressSpace addrspace = AddressSpace.fromTag(tag);
        final DataAnnotation dataAnnotation = DataAnnotation.fromJson(
          area,
          addrspace,
          data[tag] as Map<String, dynamic>,
        );
        area.dataAnnotations.add(dataAnnotation);
      }
    }

    final List<AnnotationBase> annotations = <AnnotationBase>[
      ...area.subAreas,
      ...area.codeAnnotations,
      ...area.dataAnnotations,
    ];

    for (int i = 0; i < annotations.length - 1; i++) {
      for (int j = i + 1; j < annotations.length; j++) {
        assert(annotations[i]
                .addressSpace
                .intersect(annotations[j].addressSpace) ==
            false);
      }
    }

    return area;
  }

  final AnnotatedArea parent;
  final String name;
  final List<AnnotatedArea> subAreas;
  final List<CodeAnnotation> codeAnnotations;
  final List<DataAnnotation> dataAnnotations;

  @override
  List<Object> get props => <Object>[
        parent,
        name,
        subAreas,
        codeAnnotations,
        dataAnnotations,
      ];
}
