import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lcd_offsets_model.g.dart';

double _intToDouble(int value) => value.toDouble();

@JsonSerializable(
  createFactory: true,
  createToJson: false,
)
class LcdOffsetsModel {
  const LcdOffsetsModel({
    @required this.horizontal,
    @required this.vertical,
  });

  factory LcdOffsetsModel.fromJson(Map<String, dynamic> json) =>
      _$LcdOffsetsModelFromJson(json);

  @JsonKey(required: true, fromJson: _intToDouble)
  final double horizontal;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double vertical;
}
