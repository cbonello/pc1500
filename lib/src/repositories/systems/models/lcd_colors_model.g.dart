// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_colors_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdColorsModel _$LcdColorsModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'background',
    'pixel-On',
    'pixel-Off',
    'symbol-On',
    'symbol-Off'
  ]);
  return LcdColorsModel(
    background: _colorToInt(json['background'] as String),
    pixelOn: _colorToInt(json['pixel-On'] as String),
    pixelOff: _colorToInt(json['pixel-Off'] as String),
    symbolOn: _colorToInt(json['symbol-On'] as String),
    symbolOff: _colorToInt(json['symbol-Off'] as String),
  );
}
