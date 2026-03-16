import 'package:json_annotation/json_annotation.dart';

import 'package:pc1500/src/repositories/systems/models/json_converters.dart';
import 'package:pc1500/src/repositories/systems/models/lcd_colors_model.dart';
import 'package:pc1500/src/repositories/systems/models/lcd_margin_model.dart';
import 'package:pc1500/src/repositories/systems/models/lcd_pixels_model.dart';
import 'package:pc1500/src/repositories/systems/models/lcd_symbols_model.dart';

part 'lcd_model.g.dart';

@JsonSerializable(createFactory: true, createToJson: false)
class LcdModel {
  const LcdModel({
    required this.colors,
    required this.margin,
    required this.symbols,
    required this.pixels,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory LcdModel.fromJson(Map<String, dynamic> json) =>
      _$LcdModelFromJson(json);

  @JsonKey(required: true)
  final LcdColorsModel colors;

  @JsonKey(required: true)
  final LcdMarginModel margin;

  @JsonKey(required: true)
  final LcdSymbolsModel symbols;

  @JsonKey(required: true)
  final LcdPixelsModel pixels;

  @JsonKey(required: true, fromJson: intToDouble)
  final double left;

  @JsonKey(required: true, fromJson: intToDouble)
  final double top;

  @JsonKey(required: true, fromJson: intToDouble)
  final double width;

  @JsonKey(required: true, fromJson: intToDouble)
  final double height;
}
