import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'key_model.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: false,
  explicitToJson: true,
)
class KeyModel {
  const KeyModel({
    @required this.color,
    @required this.fontSize,
    @required this.top,
    @required this.left,
    @required this.width,
    @required this.height,
  });

  factory KeyModel.fromJson(Map<String, dynamic> json) =>
      _$KeyModelFromJson(json);

  @JsonKey(required: true, nullable: false)
  final String color;

  @JsonKey(name: 'font-size', required: true, nullable: false)
  final int fontSize;

  @JsonKey(required: true, nullable: false)
  final int top;

  @JsonKey(required: true, nullable: false)
  final int left;

  @JsonKey(required: true, nullable: false)
  final int width;

  @JsonKey(required: true, nullable: false)
  final int height;
}
