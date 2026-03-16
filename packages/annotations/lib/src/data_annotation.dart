import 'package:annotations/src/address_space.dart';
import 'package:annotations/src/annotated_area.dart';
import 'package:annotations/src/base_annotation.dart';
import 'package:annotations/src/exception.dart';
import 'package:meta/meta.dart';

enum DataAnnotationType {
  data,
  fixedCharacterVariable,
  fixedNumericalVariable,
  arithmeticRegister,
}

@immutable
class DataAnnotation extends AnnotationBase {
  const DataAnnotation._({
    required this.area,
    required AddressSpace addressSpace,
    String? label,
    required String comment,
    this.type,
  }) : super(label: label, addressSpace: addressSpace, comment: comment);

  factory DataAnnotation.fromJson(
    AnnotatedArea area,
    AddressSpace addressSpace,
    Map<String, dynamic> json,
  ) {
    if (area.addressSpace.containsAddress(addressSpace.start) == false) {
      throw AnnotationsError(
        'DataAnnotation: area ${area.addressSpace} does not include annotation '
        '$addressSpace',
      );
    }

    final jsonType = json['type'] as String? ?? 'data';
    DataAnnotationType type;

    switch (jsonType) {
      case 'data':
        type = DataAnnotationType.data;
      case 'fixed_char_var':
        type = DataAnnotationType.fixedCharacterVariable;
      case 'fixed_num_var':
        type = DataAnnotationType.fixedNumericalVariable;
      case 'arith_reg':
        type = DataAnnotationType.arithmeticRegister;
      default:
        throw AnnotationsError(
          'DataAnnotation: Invalid data annotation type "$jsonType"',
        );
    }

    final label = json['label'] as String?;
    final comment = json['comment'] as String?;
    if (comment == null) {
      throw AnnotationsError(
        'DataAnnotation: area ${area.addressSpace} : Missing comment',
      );
    }

    return DataAnnotation._(
      area: area,
      addressSpace: addressSpace,
      label: label,
      comment: comment,
      type: type,
    );
  }

  final AnnotatedArea area;
  final DataAnnotationType? type;
}
