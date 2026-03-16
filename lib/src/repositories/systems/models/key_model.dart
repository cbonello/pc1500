import 'package:json_annotation/json_annotation.dart';

import 'package:pc1500/src/repositories/systems/models/json_converters.dart';
import 'package:pc1500/src/repositories/systems/models/key_label_model.dart';

part 'key_model.g.dart';

@JsonSerializable(createFactory: true, createToJson: false)
class KeyModel {
  const KeyModel({
    required this.label,
    required this.color,
    required this.fontSize,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  factory KeyModel.fromJson(Map<String, dynamic> json) =>
      _$KeyModelFromJson(json);

  @JsonKey(required: true)
  final KeyLabelModel label;

  @JsonKey(required: true)
  final String color;

  @JsonKey(name: 'font-size', required: true, fromJson: intToDouble)
  final double fontSize;

  @JsonKey(required: true, fromJson: intToDouble)
  final double top;

  @JsonKey(required: true, fromJson: intToDouble)
  final double left;

  @JsonKey(required: true, fromJson: intToDouble)
  final double width;

  @JsonKey(required: true, fromJson: intToDouble)
  final double height;
}
