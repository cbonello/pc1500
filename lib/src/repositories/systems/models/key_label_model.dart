import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'key_label_model.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: false,
)
class KeyLabelModel {
  const KeyLabelModel({
    @required this.type,
    @required this.value,
  });

  factory KeyLabelModel.fromJson(Map<String, dynamic> json) =>
      _$KeyLabelModelFromJson(json);

  @JsonKey(required: true, nullable: false)
  final String type;

  @JsonKey(required: true, nullable: false)
  final String value;
}
