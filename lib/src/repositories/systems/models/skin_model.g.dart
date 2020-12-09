// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkinModel _$SkinModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['key-colors', 'lcd', 'keys']);
  return SkinModel(
    keyColors: (json['key-colors'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, ColorModel.fromJson(e as Map<String, dynamic>)),
    ),
    lcd: LCDModel.fromJson(json['lcd'] as Map<String, dynamic>),
    keys: (json['keys'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, KeyModel.fromJson(e as Map<String, dynamic>)),
    ),
  );
}
