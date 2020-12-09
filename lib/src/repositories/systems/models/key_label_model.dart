import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'key_label_model.freezed.dart';
part 'key_label_model.g.dart';

@Freezed(unionKey: 'type')
abstract class KeyLabelModel with _$KeyLabelModel {
  const factory KeyLabelModel.text(String value) = KeyLabelModelText;

  const factory KeyLabelModel.icon(String value) = KeyLabelModelIcon;

  factory KeyLabelModel.fromJson(Map<String, dynamic> json) =>
      _$KeyLabelModelFromJson(json);
}
