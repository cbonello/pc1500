// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_margin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdMarginModel _$LcdMarginModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['left', 'top', 'right', 'bottom']);
  return LcdMarginModel(
    left: intToDouble((json['left'] as num).toInt()),
    top: intToDouble((json['top'] as num).toInt()),
    right: intToDouble((json['right'] as num).toInt()),
    bottom: intToDouble((json['bottom'] as num).toInt()),
  );
}
