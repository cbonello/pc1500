// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkinModel _$SkinModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['colors', 'lcd', 'keys']);
  return SkinModel(
    colors: (json['colors'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, ColorModel.fromJson(e as Map<String, dynamic>)),
    ),
    lcd: LCDModel.fromJson(json['lcd'] as Map<String, dynamic>),
    keys: (json['keys'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, KeyModel.fromJson(e as Map<String, dynamic>)),
    ),
  );
}
