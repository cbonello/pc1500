import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'skin_model.g.dart';

@JsonSerializable(createFactory: true, createToJson: false, explicitToJson: true)
class SkinModel {
  const SkinModel({
    required this.image,
    required this.lcd,
    required this.keyColors,
    required this.keys,
  });

  factory SkinModel.fromJson(Map<String, dynamic> json) =>
      _$SkinModelFromJson(json);

  @JsonKey(required: true)
  final String image;

  @JsonKey(required: true)
  final LcdModel lcd;

  @JsonKey(name: 'key-colors', required: true)
  final Map<String, ColorModel> keyColors;

  @JsonKey(required: true)
  final Map<String, KeyModel> keys;
}
