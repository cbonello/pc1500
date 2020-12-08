// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyModel _$KeyModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'label',
    'color',
    'font-size',
    'top',
    'left',
    'width',
    'height'
  ]);
  return KeyModel(
    label: json['label'] as String,
    color: json['color'] as String,
    fontSize: _intToDouble(json['font-size'] as int),
    top: _intToDouble(json['top'] as int),
    left: _intToDouble(json['left'] as int),
    width: _intToDouble(json['width'] as int),
    height: _intToDouble(json['height'] as int),
  );
}
