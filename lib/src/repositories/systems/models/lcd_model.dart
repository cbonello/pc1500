import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lcd_model.g.dart';

double _intToDouble(int value) => value.toDouble();

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

  @JsonKey(required: true, nullable: false, fromJson: _intToDouble)
  final double top;

  @JsonKey(required: true, nullable: false, fromJson: _intToDouble)
  final double left;

  @JsonKey(required: true, nullable: false, fromJson: _intToDouble)
  final double width;

  @JsonKey(required: true, nullable: false, fromJson: _intToDouble)
  final double height;
}
