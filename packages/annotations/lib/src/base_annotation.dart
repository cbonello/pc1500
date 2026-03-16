import 'package:annotations/src/address_space.dart';
import 'package:annotations/src/exception.dart';

abstract class AnnotationBase {
  const AnnotationBase({this.label, required this.addressSpace, this.comment});

  final AddressSpace addressSpace;
  final String? label;
  final String? comment;

  void mapAddress(Map<int, AnnotationBase> bank) {
    final Iterator<int> iterator = addressSpace.iterator;

    while (iterator.moveNext()) {
      if (bank.containsKey(iterator.current)) {
        throw AnnotationsError(
          '$runtimeType: Address ${iterator.current} is already annotated',
        );
      }
      bank[iterator.current] = this;
    }
  }

  void addSymbol(Map<String, AnnotationBase> symbolTable) {
    if (label != null) {
      if (symbolTable.containsKey(label)) {
        throw AnnotationsError(
          '$runtimeType: Symbol $label is already defined',
        );
      }
      symbolTable[label!] = this;
    }
  }
}
