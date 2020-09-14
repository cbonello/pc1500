import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'skin_model.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: false,
  explicitToJson: true,
)
class SkinModel {
  const SkinModel({
    @required this.colors,
    @required this.lcd,
    @required this.keys,
  });

  factory SkinModel.fromJson(Map<String, dynamic> json) =>
      _$SkinModelFromJson(json);

  @JsonKey(required: true, nullable: false)
  final Map<String, ColorModel> colors;

  @JsonKey(required: true, nullable: false)
  final LCDModel lcd;

  @JsonKey(required: true, nullable: false)
  final Map<String, KeyModel> keys;
}
