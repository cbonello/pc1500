// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_margin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdMarginModel _$LcdMarginModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['left', 'top', 'right', 'bottom']);
  return LcdMarginModel(
    left: _intToDouble(json['left'] as int),
    top: _intToDouble(json['top'] as int),
    right: _intToDouble(json['right'] as int),
    bottom: _intToDouble(json['bottom'] as int),
  );
}
