// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyModel _$KeyModelFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'label',
      'color',
      'font-size',
      'top',
      'left',
      'width',
      'height',
    ],
  );
  return KeyModel(
    label: KeyLabelModel.fromJson(json['label'] as Map<String, dynamic>),
    color: json['color'] as String,
    fontSize: intToDouble((json['font-size'] as num).toInt()),
    top: intToDouble((json['top'] as num).toInt()),
    left: intToDouble((json['left'] as num).toInt()),
    width: intToDouble((json['width'] as num).toInt()),
    height: intToDouble((json['height'] as num).toInt()),
  );
}
