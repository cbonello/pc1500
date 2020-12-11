import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'lcd_colors_model.dart';
import 'lcd_offsets_model.dart';

part 'lcd_model.g.dart';

double _intToDouble(int value) => value.toDouble();

@JsonSerializable(
  createFactory: true,
  createToJson: false,
)
class LcdModel {
  const LcdModel({
    @required this.colors,
    @required this.offsets,
    @required this.top,
    @required this.left,
    @required this.width,
    @required this.height,
  });

  factory LcdModel.fromJson(Map<String, dynamic> json) =>
      _$LcdModelFromJson(json);

  @JsonKey(required: true, nullable: false)
  final LcdColorsModel colors;

  @JsonKey(required: true, nullable: false)
  final LcdOffsetsModel offsets;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double top;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double left;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double width;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double height;
}
