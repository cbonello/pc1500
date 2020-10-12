import 'package:meta/meta.dart';

import 'address_space.dart';
import 'annotated_area.dart';
import 'base_annotation.dart';
import 'exception.dart';

enum DataAnnotationType {
  data,
  fixedCharacterVariable,
  fixedNumericalVariable,
  arithmeticRegister,
}

@immutable
class DataAnnotation extends AnnotationBase {
  const DataAnnotation._({
    @required this.area,
    @required AddressSpace addressSpace,
    String label,
    @required String comment,
    this.type,
  }) : super(
          label: label,
          addressSpace: addressSpace,
          comment: comment,
        );

  factory DataAnnotation.fromJson(
    AnnotatedArea area,
    AddressSpace addressSpace,
    Map<String, dynamic> json,
  ) {
    if (area == null || area is! AnnotatedArea) {
      throw AnnotationsError('DataAnnotation: Invalid area');
    }
    if (addressSpace == null || addressSpace is! AddressSpace) {
      throw AnnotationsError('DataAnnotation: Invalid address-space');
    }
    if (area.addressSpace.containsAddress(addressSpace.start) == false) {
      throw AnnotationsError(
        'DataAnnotation: area ${area.addressSpace} does not include annotation $addressSpace',
      );
    }

    final String jsonType = json['type'] as String ?? 'data';
    DataAnnotationType type;

    switch (jsonType) {
      case 'data':
        type = DataAnnotationType.data;
        break;
      case 'fixed_char_var':
        type = DataAnnotationType.fixedCharacterVariable;
        break;
      case 'fixed_num_var':
        type = DataAnnotationType.fixedNumericalVariable;
        break;
      case 'arith_reg':
        type = DataAnnotationType.arithmeticRegister;
        break;
      default:
        throw AnnotationsError(
          'DataAnnotation: Invalid data annotation type "$jsonType"',
        );
    }

    final String label = json['label'] as String;
    final String comment = json['comment'] as String;
    if (comment == null) {
      throw AnnotationsError(
        'AddressSpace: area ${area.addressSpace} : Missing comment',
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
  final DataAnnotationType type;

  @override
  void mapAddress(Map<int, AnnotationBase> bank) {
    final Iterator<int> iterator = addressSpace.iterator;

    while (iterator.moveNext()) {
      if (bank.containsKey(iterator.current)) {
        throw AnnotationsError(
          'DataAnnotation: Address ${iterator.current} is already annotated',
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
          'DataAnnotation: Symbol $label is already defined',
        );
      }
      symbolTable[label] = this;
    }
  }
}
