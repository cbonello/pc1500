import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lcd_symbols_model.g.dart';

@JsonSerializable(
  createFactory: true,
  createToJson: false,
)
class LcdSymbolsModel {
  const LcdSymbolsModel({
    @required this.busy,
    @required this.shift,
    @required this.small,
    @required this.def,
    @required this.one,
    @required this.two,
    @required this.three,
    @required this.de,
    @required this.g,
    @required this.rad,
    @required this.run,
    @required this.pro,
    @required this.reserve,
  });

  factory LcdSymbolsModel.fromJson(Map<String, dynamic> json) =>
      _$LcdSymbolsModelFromJson(json);

  @JsonKey(required: true, nullable: false)
  final double busy;

  @JsonKey(required: true, nullable: false)
  final double shift;

  @JsonKey(required: true, nullable: false)
  final double small;

  @JsonKey(required: true, nullable: false)
  final double def;

  @JsonKey(name: '1', required: true, nullable: false)
  final double one;

  @JsonKey(name: '2', required: true, nullable: false)
  final double two;

  @JsonKey(name: '3', required: true, nullable: false)
  final double three;

  @JsonKey(required: true, nullable: false)
  final double de;

  @JsonKey(required: true, nullable: false)
  final double g;

  @JsonKey(required: true, nullable: false)
  final double rad;

  @JsonKey(required: true, nullable: false)
  final double run;

  @JsonKey(required: true, nullable: false)
  final double pro;

  @JsonKey(required: true, nullable: false)
  final double reserve;
}
