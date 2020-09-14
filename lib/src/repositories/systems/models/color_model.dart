import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'color_model.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: false,
  explicitToJson: true,
)
class ColorModel {
  const ColorModel({
    @required this.background,
    @required this.border,
    @required this.color,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) =>
      _$ColorModelFromJson(json);

  @JsonKey(required: true, nullable: false)
  final String background;

  @JsonKey(required: true, nullable: false)
  final String border;

  @JsonKey(required: true, nullable: false)
  final String color;
}
