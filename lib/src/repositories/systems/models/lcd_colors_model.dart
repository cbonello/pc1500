import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'lcd_colors_model.g.dart';

@JsonSerializable(createFactory: true, createToJson: false)
class LcdColorsModel {
  const LcdColorsModel({
    required this.background,
    required this.pixelOn,
    required this.pixelOff,
    required this.symbolOn,
    required this.symbolOff,
  });

  factory LcdColorsModel.fromJson(Map<String, dynamic> json) =>
      _$LcdColorsModelFromJson(json);

  @JsonKey(required: true, fromJson: colorToInt)
  final int background;

  @JsonKey(name: 'pixel-On', required: true, fromJson: colorToInt)
  final int pixelOn;

  @JsonKey(name: 'pixel-Off', required: true, fromJson: colorToInt)
  final int pixelOff;

  @JsonKey(name: 'symbol-On', required: true, fromJson: colorToInt)
  final int symbolOn;

  @JsonKey(name: 'symbol-Off', required: true, fromJson: colorToInt)
  final int symbolOff;
}
