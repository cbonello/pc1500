import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lcd_margin_model.g.dart';

double _intToDouble(int value) => value.toDouble();

@JsonSerializable(
  createFactory: true,
  createToJson: false,
)
class LcdMarginModel {
  const LcdMarginModel({
    @required this.left,
    @required this.top,
    @required this.right,
    @required this.bottom,
  });

  factory LcdMarginModel.fromJson(Map<String, dynamic> json) =>
      _$LcdMarginModelFromJson(json);

  @JsonKey(required: true, fromJson: _intToDouble)
  final double left;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double top;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double right;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double bottom;
}
