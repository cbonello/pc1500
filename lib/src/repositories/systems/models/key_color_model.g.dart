// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_color_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorModel _$ColorModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['background', 'border', 'color']);
  return ColorModel(
    background: colorToInt(json['background'] as String),
    border: colorToInt(json['border'] as String),
    color: colorToInt(json['color'] as String),
  );
}
