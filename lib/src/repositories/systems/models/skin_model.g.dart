// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkinModel _$SkinModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['image', 'lcd', 'key-colors', 'keys']);
  return SkinModel(
    image: json['image'] as String,
    lcd: LcdModel.fromJson(json['lcd'] as Map<String, dynamic>),
    keyColors: (json['key-colors'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, ColorModel.fromJson(e as Map<String, dynamic>)),
    ),
    keys: (json['keys'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, KeyModel.fromJson(e as Map<String, dynamic>)),
    ),
  );
}
