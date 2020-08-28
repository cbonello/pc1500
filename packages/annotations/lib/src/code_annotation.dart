import 'package:meta/meta.dart';

import 'address_space.dart';
import 'annotated_area.dart';
import 'base_annotation.dart';
import 'exception.dart';

@immutable
class CodeAnnotation extends AnnotationBase {
  const CodeAnnotation._({
    @required this.area,
    @required AddressSpace addressSpace,
    this.label,
    this.comment,
  }) : super(addressSpace: addressSpace);

  factory CodeAnnotation.fromJson(
    AnnotatedArea area,
    AddressSpace addressSpace,
    Map<String, dynamic> json,
  ) {
    if (area == null || area is! AnnotatedArea) {
      throw AnnotationsError('CodeAnnotation: Invalid area');
    }
    if (addressSpace == null ||
        addressSpace is! AddressSpace ||
        addressSpace.length != 1) {
      throw AnnotationsError('CodeAnnotation: Invalid address-space');
    }
    if (area.addressSpace.containsAddress(addressSpace.start) == false) {
      throw AnnotationsError(
        'CodeAnnotation: area ${area.addressSpace} does not include annotation $addressSpace',
      );
    }

    final String label = json['label'] as String;
    final String comment = json['comment'] as String;
    if (label == null && comment == null) {
      throw AnnotationsError(
        'AddressSpace: area ${area.addressSpace} : Missing label or comment',
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
  final String label;
  final String comment;

  @override
  void mapAddress(Map<int, AnnotationBase> bank) {
    final Iterator<int> iterator = addressSpace.iterator;

    while (iterator.moveNext()) {
      if (bank.containsKey(iterator.current)) {
        throw AnnotationsError(
          'CodeAnnotation: Address ${iterator.current} is already annotated',
        );
      }
      bank[iterator.current] = this;
    }
  }

  @override
  void addSymbol(Map<String, AnnotationBase> symbolTable) {
    if (label != null) {
      if (symbolTable.containsKey(label)) {
        throw AnnotationsError(
          'CodeAnnotation: Symbol $label is already defined',
        );
      }
      symbolTable[label] = this;
    }
  }
}
