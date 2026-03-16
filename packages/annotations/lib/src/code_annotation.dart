import 'package:annotations/src/address_space.dart';
import 'package:annotations/src/annotated_area.dart';
import 'package:annotations/src/base_annotation.dart';
import 'package:annotations/src/exception.dart';
import 'package:meta/meta.dart';

@immutable
class CodeAnnotation extends AnnotationBase {
  const CodeAnnotation._({
    required this.area,
    required AddressSpace addressSpace,
    String? label,
    String? comment,
  }) : super(label: label, addressSpace: addressSpace, comment: comment);

  factory CodeAnnotation.fromJson(
    AnnotatedArea area,
    AddressSpace addressSpace,
    Map<String, dynamic> json,
  ) {
    if (addressSpace.length != 1) {
      throw AnnotationsError('CodeAnnotation: Invalid address-space');
    }
    if (area.addressSpace.containsAddress(addressSpace.start) == false) {
      throw AnnotationsError(
        'CodeAnnotation: area ${area.addressSpace} does not include annotation '
        '$addressSpace',
      );
    }

    final label = json['label'] as String?;
    final comment = json['comment'] as String?;
    if (label == null && comment == null) {
      throw AnnotationsError(
        'CodeAnnotation: area ${area.addressSpace} : Missing label or comment',
      );
    }

    return CodeAnnotation._(
      area: area,
      addressSpace: addressSpace,
      label: label,
      comment: comment,
    );
  }

  final AnnotatedArea area;
}
