import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lcd_model.g.dart';

double _intToDouble(int value) => value.toDouble();

int _colorToInt(String value) => int.tryParse(value, radix: 16);

@JsonSerializable(
  createFactory: true,
  createToJson: false,
)
class LCDModel {
  const LCDModel({
    @required this.background,
    @required this.pixelOff,
    @required this.pixelOn,
    @required this.symbolOn,
    @required this.symbolOff,
    @required this.top,
    @required this.left,
    @required this.width,
    @required this.height,
  });

  factory LCDModel.fromJson(Map<String, dynamic> json) =>
      _$LCDModelFromJson(json);

  @JsonKey(required: true, fromJson: _colorToInt)
  final int background;

  @JsonKey(name: 'pixel-On', required: true, fromJson: _colorToInt)
  final int pixelOn;

  @JsonKey(name: 'pixel-Off', required: true, fromJson: _colorToInt)
  final int pixelOff;

  @JsonKey(name: 'symbol-On', required: true, fromJson: _colorToInt)
  final int symbolOn;

  @JsonKey(name: 'symbol-Off', required: true, fromJson: _colorToInt)
  final int symbolOff;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double top;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double left;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double width;

  @JsonKey(required: true, fromJson: _intToDouble)
  final double height;
}
