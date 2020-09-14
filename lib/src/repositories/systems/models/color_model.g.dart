// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorModel _$ColorModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['background', 'border', 'color']);
  return ColorModel(
    background: json['background'] as String,
    border: json['border'] as String,
    color: json['color'] as String,
  );
}
