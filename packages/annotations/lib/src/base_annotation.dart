import 'package:meta/meta.dart';

import 'address_space.dart';

abstract class AnnotationBase {
  const AnnotationBase({
    this.label,
    @required this.addressSpace,
    this.comment,
  }) : assert(addressSpace != null);

  final AddressSpace addressSpace;
  final String label;
  final String comment;

  void mapAddress(Map<int, AnnotationBase> bank);
  void addSymbol(Map<String, AnnotationBase> symbolTable);
}
