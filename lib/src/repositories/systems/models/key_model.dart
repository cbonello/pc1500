import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'key_model.g.dart';

double _intToDouble(int value) => value.toDouble();

@JsonSerializable(
  createFactory: true,
  createToJson: false,
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

  @JsonKey(required: true, fromJson: _intToDouble)
  final double top;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double left;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double width;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double height;
}
