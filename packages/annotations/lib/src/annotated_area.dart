import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'address_space.dart';
import 'base_annotation.dart';
import 'code_annotation.dart';
import 'data_annotation.dart';
import 'exception.dart';

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
    if (addressSpace == null) {
      throw AnnotationsError('AnnotatedArea: Missing address-space');
    }
    if (name == null) {
      throw AnnotationsError('AnnotatedArea: Missing name');
    }

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
    if (name == null) {
      throw AnnotationsError(
        'AnnotatedArea: $addressSpace: Missing area name',
      );
    }

    final AnnotatedArea area = AnnotatedArea.empty(
      parent: parent,
      addressSpace: addressSpace,
      name: name,
    );

    final Map<String, dynamic> areas = json['areas'] as Map<String, dynamic>;
    if (areas != null) {
      for (final String tag in areas.keys) {
        if (areas[tag] == null) {
          throw AnnotationsError(
            'AnnotatedArea: $addressSpace: Invalid area "$tag"',
          );
        }

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
        if (code[tag] == null) {
          throw AnnotationsError(
            'AnnotatedArea: $addressSpace: Invalid code area "$tag"',
          );
        }

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
        if (data[tag] == null) {
          throw AnnotationsError(
            'AnnotatedArea: $addressSpace: Invalid data area "$tag"',
          );
        }

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
        if (annotations[i]
                .addressSpace
                .intersectWith(annotations[j].addressSpace) ==
            true) {
          throw AnnotationsError(
            'AnnotatedArea: ${annotations[i].addressSpace} and ${annotations[j].addressSpace} intersect',
          );
        }
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
  void mapAddress(Map<int, AnnotationBase> bank) {
    for (final AnnotatedArea s in subAreas) {
      s.mapAddress(bank);
    }
    for (final CodeAnnotation c in codeAnnotations) {
      c.mapAddress(bank);
    }
    for (final DataAnnotation d in dataAnnotations) {
      d.mapAddress(bank);
    }
  }

  @override
  void addSymbol(Map<String, AnnotationBase> symbolTable) {
    for (final AnnotatedArea s in subAreas) {
      s.addSymbol(symbolTable);
    }
    for (final CodeAnnotation c in codeAnnotations) {
      c.addSymbol(symbolTable);
    }
    for (final DataAnnotation d in dataAnnotations) {
      d.addSymbol(symbolTable);
    }
  }

  @override
  List<Object> get props => <Object>[
        parent,
        name,
        subAreas,
        codeAnnotations,
        dataAnnotations,
      ];
}
