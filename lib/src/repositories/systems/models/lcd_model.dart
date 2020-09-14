import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lcd_model.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: false,
  explicitToJson: true,
)
class LCDModel {
  const LCDModel({
    @required this.top,
    @required this.left,
    @required this.width,
    @required this.height,
  });

  factory LCDModel.fromJson(Map<String, dynamic> json) =>
      _$LCDModelFromJson(json);

  @JsonKey(required: true, nullable: false)
  final int top;

  @JsonKey(required: true, nullable: false)
  final int left;

  @JsonKey(required: true, nullable: false)
  final int width;

  @JsonKey(required: true, nullable: false)
  final int height;
}
