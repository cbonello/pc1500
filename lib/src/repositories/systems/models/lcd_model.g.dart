// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdModel _$LcdModelFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'colors',
      'margin',
      'symbols',
      'pixels',
      'left',
      'top',
      'width',
      'height',
    ],
  );
  return LcdModel(
    colors: LcdColorsModel.fromJson(json['colors'] as Map<String, dynamic>),
    margin: LcdMarginModel.fromJson(json['margin'] as Map<String, dynamic>),
    symbols: LcdSymbolsModel.fromJson(json['symbols'] as Map<String, dynamic>),
    pixels: LcdPixelsModel.fromJson(json['pixels'] as Map<String, dynamic>),
    left: intToDouble((json['left'] as num).toInt()),
    top: intToDouble((json['top'] as num).toInt()),
    width: intToDouble((json['width'] as num).toInt()),
    height: intToDouble((json['height'] as num).toInt()),
  );
}
