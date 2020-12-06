// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LCDModel _$LCDModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['top', 'left', 'width', 'height']);
  return LCDModel(
    top: _intToDouble(json['top'] as int),
    left: _intToDouble(json['left'] as int),
    width: _intToDouble(json['width'] as int),
    height: _intToDouble(json['height'] as int),
  );
}
