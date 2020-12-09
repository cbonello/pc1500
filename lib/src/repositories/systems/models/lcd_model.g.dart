// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LCDModel _$LCDModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'background',
    'pixel-Off',
    'pixel-On',
    'symbol-On',
    'symbol-Off',
    'top',
    'left',
    'width',
    'height'
  ]);
  return LCDModel(
    background: _colorToInt(json['background'] as String),
    pixelOff: _colorToInt(json['pixel-Off'] as String),
    pixelOn: _colorToInt(json['pixel-On'] as String),
    symbolOn: _colorToInt(json['symbol-On'] as String),
    symbolOff: _colorToInt(json['symbol-Off'] as String),
    top: _intToDouble(json['top'] as int),
    left: _intToDouble(json['left'] as int),
    width: _intToDouble(json['width'] as int),
    height: _intToDouble(json['height'] as int),
  );
}
