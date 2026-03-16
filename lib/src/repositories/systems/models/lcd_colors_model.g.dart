// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_colors_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdColorsModel _$LcdColorsModelFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'background',
      'pixel-On',
      'pixel-Off',
      'symbol-On',
      'symbol-Off',
    ],
  );
  return LcdColorsModel(
    background: colorToInt(json['background'] as String),
    pixelOn: colorToInt(json['pixel-On'] as String),
    pixelOff: colorToInt(json['pixel-Off'] as String),
    symbolOn: colorToInt(json['symbol-On'] as String),
    symbolOff: colorToInt(json['symbol-Off'] as String),
  );
}
