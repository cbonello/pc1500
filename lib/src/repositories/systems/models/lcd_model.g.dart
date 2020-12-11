// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdModel _$LcdModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'colors',
    'offsets',
    'top',
    'left',
    'width',
    'height'
  ]);
  return LcdModel(
    colors: LcdColorsModel.fromJson(json['colors'] as Map<String, dynamic>),
    offsets: LcdOffsetsModel.fromJson(json['offsets'] as Map<String, dynamic>),
    top: _intToDouble(json['top'] as int),
    left: _intToDouble(json['left'] as int),
    width: _intToDouble(json['width'] as int),
    height: _intToDouble(json['height'] as int),
  );
}
