// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_symbols_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdSymbolsModel _$LcdSymbolsModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'busy',
    'shift',
    'small',
    'def',
    '1',
    '2',
    '3',
    'de',
    'g',
    'rad',
    'run',
    'pro',
    'reserve'
  ]);
  return LcdSymbolsModel(
    busy: (json['busy'] as num).toDouble(),
    shift: (json['shift'] as num).toDouble(),
    small: (json['small'] as num).toDouble(),
    def: (json['def'] as num).toDouble(),
    one: (json['1'] as num).toDouble(),
    two: (json['2'] as num).toDouble(),
    three: (json['3'] as num).toDouble(),
    de: (json['de'] as num).toDouble(),
    g: (json['g'] as num).toDouble(),
    rad: (json['rad'] as num).toDouble(),
    run: (json['run'] as num).toDouble(),
    pro: (json['pro'] as num).toDouble(),
    reserve: (json['reserve'] as num).toDouble(),
  );
}
