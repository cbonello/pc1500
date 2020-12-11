// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_offsets_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdOffsetsModel _$LcdOffsetsModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['horizontal', 'vertical']);
  return LcdOffsetsModel(
    horizontal: _intToDouble(json['horizontal'] as int),
    vertical: _intToDouble(json['vertical'] as int),
  );
}
