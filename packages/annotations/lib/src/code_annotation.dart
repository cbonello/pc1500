import 'package:meta/meta.dart';

import 'address_space.dart';
import 'annotated_area.dart';
import 'base_annotation.dart';

@immutable
class CodeAnnotation extends AnnotationBase {
  const CodeAnnotation._({
    @required this.area,
    @required AddressSpace addressSpace,
    this.label,
    this.comment,
  })  : assert(area != null),
        assert(addressSpace != null),
        assert(label != null || comment != null),
        super(addressSpace: addressSpace);

  factory CodeAnnotation.fromJson(
    AnnotatedArea area,
    AddressSpace addressSpace,
    Map<String, dynamic> json,
  ) {
    assert(area != null && area is AnnotatedArea);
    assert(
      addressSpace != null &&
          addressSpace is AddressSpace &&
          addressSpace.length == 1,
    );
    assert(area.addressSpace.containsAddress(addressSpace.start));

    return CodeAnnotation._(
      area: area,
      addressSpace: addressSpace,
      label: json['label'] as String,
      comment: json['comment'] as String,
    );
  }

  final AnnotatedArea area;
  final String label;
  final String comment;

  @override
  void mapAddress(Map<int, AnnotationBase> bank) {
    final Iterator<int> iterator = addressSpace.iterator;

    while (iterator.moveNext()) {
      assert(bank.containsKey(iterator.current) == false);
      bank[iterator.current] = this;
    }
  }

  @override
  void addSymbol(Map<String, AnnotationBase> symbolTable) {
    if (label != null) {
      assert(symbolTable.containsKey(label) == false);
      symbolTable[label] = this;
    }
  }
}
