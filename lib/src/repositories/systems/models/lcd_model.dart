import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'lcd_colors_model.dart';
import 'lcd_margin_model.dart';
import 'lcd_pixels_model.dart';
import 'lcd_symbols_model.dart';

part 'lcd_model.g.dart';

double _intToDouble(int value) => value.toDouble();

@JsonSerializable(
  createFactory: true,
  createToJson: false,
)
class LcdModel {
  const LcdModel({
    @required this.colors,
    @required this.margin,
    @required this.symbols,
    @required this.pixels,
    @required this.left,
    @required this.top,
    @required this.width,
    @required this.height,
  });

  factory LcdModel.fromJson(Map<String, dynamic> json) =>
      _$LcdModelFromJson(json);

  @JsonKey(required: true, nullable: false)
  final LcdColorsModel colors;

  @JsonKey(required: true, nullable: false)
  final LcdMarginModel margin;

  @JsonKey(required: true, nullable: false)
  final LcdSymbolsModel symbols;

  @JsonKey(required: true, nullable: false)
  final LcdPixelsModel pixels;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double left;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double top;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double width;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double height;
}
