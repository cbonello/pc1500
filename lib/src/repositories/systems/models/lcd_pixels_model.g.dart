// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_pixels_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdPixelsModel _$LcdPixelsModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['top', 'width', 'height', 'gap']);
  return LcdPixelsModel(
    top: (json['top'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
    gap: (json['gap'] as num).toDouble(),
  );
}
