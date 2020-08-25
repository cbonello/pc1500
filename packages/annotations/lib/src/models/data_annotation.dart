import 'package:meta/meta.dart';

import 'models.dart';

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
    this.label,
    @required this.comment,
    this.type,
  })  : assert(area != null),
        assert(addressSpace != null),
        assert(comment != null),
        super(addressSpace: addressSpace);

  factory DataAnnotation.fromJson(
    AnnotatedArea area,
    AddressSpace addressSpace,
    Map<String, dynamic> json,
  ) {
    assert(area != null && area is AnnotatedArea);
    assert(addressSpace != null && addressSpace is AddressSpace);
    assert(area.addressSpace.contains(addressSpace));

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
        assert(false, 'Invalid data annotation type "$jsonType"');
    }

    return DataAnnotation._(
      area: area,
      addressSpace: addressSpace,
      label: json['label'] as String,
      comment: json['comment'] as String,
      type: type,
    );
  }

  final AnnotatedArea area;
  final String label;
  final String comment;
  final DataAnnotationType type;
}
