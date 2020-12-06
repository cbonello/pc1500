// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorModel _$ColorModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['background', 'border', 'color']);
  return ColorModel(
    background: _colorToInt(json['background'] as String),
    border: _colorToInt(json['border'] as String),
    color: _colorToInt(json['color'] as String),
  );
}
