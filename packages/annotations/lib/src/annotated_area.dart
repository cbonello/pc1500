import 'package:annotations/src/address_space.dart';
import 'package:annotations/src/base_annotation.dart';
import 'package:annotations/src/code_annotation.dart';
import 'package:annotations/src/data_annotation.dart';
import 'package:annotations/src/exception.dart';
import 'package:equatable/equatable.dart';

class AnnotatedArea extends AnnotationBase with EquatableMixin {
  AnnotatedArea._({
    this.parent,
    required AddressSpace addressSpace,
    required this.name,
    required List<AnnotatedArea> subAreas,
    required List<CodeAnnotation> codeAnnotations,
    required List<DataAnnotation> dataAnnotations,
  }) : subAreas = List.unmodifiable(subAreas),
       codeAnnotations = List.unmodifiable(codeAnnotations),
       dataAnnotations = List.unmodifiable(dataAnnotations),
       super(addressSpace: addressSpace);

  factory AnnotatedArea.empty({
    AnnotatedArea? parent,
    required AddressSpace addressSpace,
    required String name,
  }) => AnnotatedArea._(
    parent: parent,
    addressSpace: addressSpace,
    name: name,
    subAreas: <AnnotatedArea>[],
    codeAnnotations: <CodeAnnotation>[],
    dataAnnotations: <DataAnnotation>[],
  );

  factory AnnotatedArea.fromJson(
    AnnotatedArea? parent,
    AddressSpace addressSpace,
    Map<String, dynamic> json,
  ) {
    if (parent != null &&
        !parent.addressSpace.containsAddress(addressSpace.start)) {
      throw AnnotationsError(
        'AnnotatedArea: $addressSpace is outside parent ${parent.addressSpace}',
      );
    }

    final name = json['name'] as String;

    // Build into temporary mutable lists, then pass to constructor for
    // unmodifiable wrapping.
    final tempSubAreas = <AnnotatedArea>[];
    final tempCodeAnnotations = <CodeAnnotation>[];
    final tempDataAnnotations = <DataAnnotation>[];

    // We need a temporary area reference for children to point back to.
    // Create the final area after all children are built.
    final AnnotatedArea area = AnnotatedArea.empty(
      parent: parent,
      addressSpace: addressSpace,
      name: name,
    );

    final areas = json['areas'] as Map<String, dynamic>?;
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
        tempSubAreas.add(subArea);
      }
    }

    final code = json['code'] as Map<String, dynamic>?;
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
        tempCodeAnnotations.add(codeAnnotation);
      }
    }

    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      for (final String tag in data.keys) {
        if (data[tag] == null) {
          throw AnnotationsError(
            'AnnotatedArea: $addressSpace: Invalid data area "$tag"',
          );
        }

        final addrspace = AddressSpace.fromTag(tag);
        final dataAnnotation = DataAnnotation.fromJson(
          area,
          addrspace,
          data[tag] as Map<String, dynamic>,
        );
        tempDataAnnotations.add(dataAnnotation);
      }
    }

    final annotations = <AnnotationBase>[
      ...tempSubAreas,
      ...tempCodeAnnotations,
      ...tempDataAnnotations,
    ];

    for (int i = 0; i < annotations.length - 1; i++) {
      for (int j = i + 1; j < annotations.length; j++) {
        if (annotations[i].addressSpace.intersectWith(
              annotations[j].addressSpace,
            ) ==
            true) {
          throw AnnotationsError(
            'AnnotatedArea: ${annotations[i].addressSpace} and '
            '${annotations[j].addressSpace} intersect',
          );
        }
      }
    }

    return AnnotatedArea._(
      parent: parent,
      addressSpace: addressSpace,
      name: name,
      subAreas: tempSubAreas,
      codeAnnotations: tempCodeAnnotations,
      dataAnnotations: tempDataAnnotations,
    );
  }

  final AnnotatedArea? parent;
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
  List<Object?> get props => [
    parent?.name,
    name,
    subAreas,
    codeAnnotations,
    dataAnnotations,
  ];
}
