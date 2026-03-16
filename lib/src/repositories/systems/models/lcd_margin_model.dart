import 'package:json_annotation/json_annotation.dart';

import 'package:pc1500/src/repositories/systems/models/json_converters.dart';

part 'lcd_margin_model.g.dart';

@JsonSerializable(createFactory: true, createToJson: false)
class LcdMarginModel {
  const LcdMarginModel({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory LcdMarginModel.fromJson(Map<String, dynamic> json) =>
      _$LcdMarginModelFromJson(json);

  @JsonKey(required: true, fromJson: intToDouble)
  final double left;

  @JsonKey(required: true, fromJson: intToDouble)
  final double top;

  @JsonKey(required: true, fromJson: intToDouble)
  final double right;

  @JsonKey(required: true, fromJson: intToDouble)
  final double bottom;
}
