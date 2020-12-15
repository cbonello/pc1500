import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lcd_pixels_model.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: false,
)
class LcdPixelsModel {
  const LcdPixelsModel({
    @required this.width,
    @required this.height,
    @required this.gap,
  });

  factory LcdPixelsModel.fromJson(Map<String, dynamic> json) =>
      _$LcdPixelsModelFromJson(json);

  @JsonKey(required: true, nullable: false)
  final double width;

  @JsonKey(required: true, nullable: false)
  final double height;

  @JsonKey(required: true, nullable: false)
  final double gap;
}
