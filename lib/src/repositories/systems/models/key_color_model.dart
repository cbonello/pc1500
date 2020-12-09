import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'key_color_model.g.dart';

int _colorToInt(String value) => int.tryParse(value, radix: 16);

@JsonSerializable(
  createFactory: true,
  createToJson: false,
)
class ColorModel {
  const ColorModel({
    @required this.background,
    @required this.border,
    @required this.color,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) =>
      _$ColorModelFromJson(json);

  @JsonKey(required: true, fromJson: _colorToInt)
  final int background;

  @JsonKey(required: true, fromJson: _colorToInt)
  final int border;

  @JsonKey(required: true, fromJson: _colorToInt)
  final int color;
}
