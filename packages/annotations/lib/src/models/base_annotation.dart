import 'package:meta/meta.dart';

import 'models.dart';

abstract class AnnotationBase {
  const AnnotationBase({@required this.addressSpace})
      : assert(addressSpace != null);

  final AddressSpace addressSpace;

  void mapAddress(Map<int, AnnotationBase> bank);
  void addSymbol(Map<String, AnnotationBase> symbolTable);
}
