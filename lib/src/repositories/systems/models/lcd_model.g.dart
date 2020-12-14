// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdModel _$LcdModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'colors',
    'margin',
    'left',
    'top',
    'width',
    'height'
  ]);
  return LcdModel(
    colors: LcdColorsModel.fromJson(json['colors'] as Map<String, dynamic>),
    margin: LcdMarginModel.fromJson(json['margin'] as Map<String, dynamic>),
    left: _intToDouble(json['left'] as int),
    top: _intToDouble(json['top'] as int),
    width: _intToDouble(json['width'] as int),
    height: _intToDouble(json['height'] as int),
  );
}
