// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyModel _$KeyModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'color',
    'font-size',
    'top',
    'left',
    'width',
    'height'
  ]);
  return KeyModel(
    color: json['color'] as String,
    fontSize: json['font-size'] as int,
    top: json['top'] as int,
    left: json['left'] as int,
    width: json['width'] as int,
    height: json['height'] as int,
  );
}
