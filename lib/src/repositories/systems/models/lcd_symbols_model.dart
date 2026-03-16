import 'package:json_annotation/json_annotation.dart';

part 'lcd_symbols_model.g.dart';

@JsonSerializable(createFactory: true, createToJson: false)
class LcdSymbolsModel {
  const LcdSymbolsModel({
    required this.busy,
    required this.shift,
    required this.small,
    required this.def,
    required this.one,
    required this.two,
    required this.three,
    required this.de,
    required this.g,
    required this.rad,
    required this.run,
    required this.pro,
    required this.reserve,
  });

  factory LcdSymbolsModel.fromJson(Map<String, dynamic> json) =>
      _$LcdSymbolsModelFromJson(json);

  @JsonKey(required: true)
  final double busy;

  @JsonKey(required: true)
  final double shift;

  @JsonKey(required: true)
  final double small;

  @JsonKey(required: true)
  final double def;

  @JsonKey(name: '1', required: true)
  final double one;

  @JsonKey(name: '2', required: true)
  final double two;

  @JsonKey(name: '3', required: true)
  final double three;

  @JsonKey(required: true)
  final double de;

  @JsonKey(required: true)
  final double g;

  @JsonKey(required: true)
  final double rad;

  @JsonKey(required: true)
  final double run;

  @JsonKey(required: true)
  final double pro;

  @JsonKey(required: true)
  final double reserve;
}
