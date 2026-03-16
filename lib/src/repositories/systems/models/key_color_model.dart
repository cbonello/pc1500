import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'key_color_model.g.dart';

@JsonSerializable(createFactory: true, createToJson: false)
class ColorModel {
  const ColorModel({
    required this.background,
    required this.border,
    required this.color,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) =>
      _$ColorModelFromJson(json);

  @JsonKey(required: true, fromJson: colorToInt)
  final int background;

  @JsonKey(required: true, fromJson: colorToInt)
  final int border;

  @JsonKey(required: true, fromJson: colorToInt)
  final int color;
}
