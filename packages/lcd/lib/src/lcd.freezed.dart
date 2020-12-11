// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'lcd.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$LcdEventTypeTearOff {
  const _$LcdEventTypeTearOff();

// ignore: unused_element
  _DisplayBufferUpdated displayBufferUpdated(
      Uint8ClampedList displayBuffer1, Uint8ClampedList displayBuffer2) {
    return _DisplayBufferUpdated(
      displayBuffer1,
      displayBuffer2,
    );
  }

// ignore: unused_element
  _SymbolUpdated symbolsUpdated(LcdSymbols symbols) {
    return _SymbolUpdated(
      symbols,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $LcdEventType = _$LcdEventTypeTearOff();

/// @nodoc
mixin _$LcdEventType {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required
        Result displayBufferUpdated(
            Uint8ClampedList displayBuffer1, Uint8ClampedList displayBuffer2),
    @required Result symbolsUpdated(LcdSymbols symbols),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result displayBufferUpdated(
        Uint8ClampedList displayBuffer1, Uint8ClampedList displayBuffer2),
    Result symbolsUpdated(LcdSymbols symbols),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result displayBufferUpdated(_DisplayBufferUpdated value),
    @required Result symbolsUpdated(_SymbolUpdated value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result displayBufferUpdated(_DisplayBufferUpdated value),
    Result symbolsUpdated(_SymbolUpdated value),
    @required Result orElse(),
  });
}

/// @nodoc
abstract class $LcdEventTypeCopyWith<$Res> {
  factory $LcdEventTypeCopyWith(
          LcdEventType value, $Res Function(LcdEventType) then) =
      _$LcdEventTypeCopyWithImpl<$Res>;
}

/// @nodoc
class _$LcdEventTypeCopyWithImpl<$Res> implements $LcdEventTypeCopyWith<$Res> {
  _$LcdEventTypeCopyWithImpl(this._value, this._then);

  final LcdEventType _value;
  // ignore: unused_field
  final $Res Function(LcdEventType) _then;
}

/// @nodoc
abstract class _$DisplayBufferUpdatedCopyWith<$Res> {
  factory _$DisplayBufferUpdatedCopyWith(_DisplayBufferUpdated value,
          $Res Function(_DisplayBufferUpdated) then) =
      __$DisplayBufferUpdatedCopyWithImpl<$Res>;
  $Res call({Uint8ClampedList displayBuffer1, Uint8ClampedList displayBuffer2});
}

/// @nodoc
class __$DisplayBufferUpdatedCopyWithImpl<$Res>
    extends _$LcdEventTypeCopyWithImpl<$Res>
    implements _$DisplayBufferUpdatedCopyWith<$Res> {
  __$DisplayBufferUpdatedCopyWithImpl(
      _DisplayBufferUpdated _value, $Res Function(_DisplayBufferUpdated) _then)
      : super(_value, (v) => _then(v as _DisplayBufferUpdated));

  @override
  _DisplayBufferUpdated get _value => super._value as _DisplayBufferUpdated;

  @override
  $Res call({
    Object displayBuffer1 = freezed,
    Object displayBuffer2 = freezed,
  }) {
    return _then(_DisplayBufferUpdated(
      displayBuffer1 == freezed
          ? _value.displayBuffer1
          : displayBuffer1 as Uint8ClampedList,
      displayBuffer2 == freezed
          ? _value.displayBuffer2
          : displayBuffer2 as Uint8ClampedList,
    ));
  }
}

/// @nodoc
class _$_DisplayBufferUpdated implements _DisplayBufferUpdated {
  const _$_DisplayBufferUpdated(this.displayBuffer1, this.displayBuffer2)
      : assert(displayBuffer1 != null),
        assert(displayBuffer2 != null);

  @override
  final Uint8ClampedList displayBuffer1;
  @override
  final Uint8ClampedList displayBuffer2;

  @override
  String toString() {
    return 'LcdEventType.displayBufferUpdated(displayBuffer1: $displayBuffer1, displayBuffer2: $displayBuffer2)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _DisplayBufferUpdated &&
            (identical(other.displayBuffer1, displayBuffer1) ||
                const DeepCollectionEquality()
                    .equals(other.displayBuffer1, displayBuffer1)) &&
            (identical(other.displayBuffer2, displayBuffer2) ||
                const DeepCollectionEquality()
                    .equals(other.displayBuffer2, displayBuffer2)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(displayBuffer1) ^
      const DeepCollectionEquality().hash(displayBuffer2);

  @override
  _$DisplayBufferUpdatedCopyWith<_DisplayBufferUpdated> get copyWith =>
      __$DisplayBufferUpdatedCopyWithImpl<_DisplayBufferUpdated>(
          this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required
        Result displayBufferUpdated(
            Uint8ClampedList displayBuffer1, Uint8ClampedList displayBuffer2),
    @required Result symbolsUpdated(LcdSymbols symbols),
  }) {
    assert(displayBufferUpdated != null);
    assert(symbolsUpdated != null);
    return displayBufferUpdated(displayBuffer1, displayBuffer2);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result displayBufferUpdated(
        Uint8ClampedList displayBuffer1, Uint8ClampedList displayBuffer2),
    Result symbolsUpdated(LcdSymbols symbols),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (displayBufferUpdated != null) {
      return displayBufferUpdated(displayBuffer1, displayBuffer2);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result displayBufferUpdated(_DisplayBufferUpdated value),
    @required Result symbolsUpdated(_SymbolUpdated value),
  }) {
    assert(displayBufferUpdated != null);
    assert(symbolsUpdated != null);
    return displayBufferUpdated(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result displayBufferUpdated(_DisplayBufferUpdated value),
    Result symbolsUpdated(_SymbolUpdated value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (displayBufferUpdated != null) {
      return displayBufferUpdated(this);
    }
    return orElse();
  }
}

abstract class _DisplayBufferUpdated implements LcdEventType {
  const factory _DisplayBufferUpdated(
          Uint8ClampedList displayBuffer1, Uint8ClampedList displayBuffer2) =
      _$_DisplayBufferUpdated;

  Uint8ClampedList get displayBuffer1;
  Uint8ClampedList get displayBuffer2;
  _$DisplayBufferUpdatedCopyWith<_DisplayBufferUpdated> get copyWith;
}

/// @nodoc
abstract class _$SymbolUpdatedCopyWith<$Res> {
  factory _$SymbolUpdatedCopyWith(
          _SymbolUpdated value, $Res Function(_SymbolUpdated) then) =
      __$SymbolUpdatedCopyWithImpl<$Res>;
  $Res call({LcdSymbols symbols});
}

/// @nodoc
class __$SymbolUpdatedCopyWithImpl<$Res>
    extends _$LcdEventTypeCopyWithImpl<$Res>
    implements _$SymbolUpdatedCopyWith<$Res> {
  __$SymbolUpdatedCopyWithImpl(
      _SymbolUpdated _value, $Res Function(_SymbolUpdated) _then)
      : super(_value, (v) => _then(v as _SymbolUpdated));

  @override
  _SymbolUpdated get _value => super._value as _SymbolUpdated;

  @override
  $Res call({
    Object symbols = freezed,
  }) {
    return _then(_SymbolUpdated(
      symbols == freezed ? _value.symbols : symbols as LcdSymbols,
    ));
  }
}

/// @nodoc
class _$_SymbolUpdated implements _SymbolUpdated {
  const _$_SymbolUpdated(this.symbols) : assert(symbols != null);

  @override
  final LcdSymbols symbols;

  @override
  String toString() {
    return 'LcdEventType.symbolsUpdated(symbols: $symbols)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SymbolUpdated &&
            (identical(other.symbols, symbols) ||
                const DeepCollectionEquality().equals(other.symbols, symbols)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(symbols);

  @override
  _$SymbolUpdatedCopyWith<_SymbolUpdated> get copyWith =>
      __$SymbolUpdatedCopyWithImpl<_SymbolUpdated>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required
        Result displayBufferUpdated(
            Uint8ClampedList displayBuffer1, Uint8ClampedList displayBuffer2),
    @required Result symbolsUpdated(LcdSymbols symbols),
  }) {
    assert(displayBufferUpdated != null);
    assert(symbolsUpdated != null);
    return symbolsUpdated(symbols);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result displayBufferUpdated(
        Uint8ClampedList displayBuffer1, Uint8ClampedList displayBuffer2),
    Result symbolsUpdated(LcdSymbols symbols),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (symbolsUpdated != null) {
      return symbolsUpdated(symbols);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result displayBufferUpdated(_DisplayBufferUpdated value),
    @required Result symbolsUpdated(_SymbolUpdated value),
  }) {
    assert(displayBufferUpdated != null);
    assert(symbolsUpdated != null);
    return symbolsUpdated(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result displayBufferUpdated(_DisplayBufferUpdated value),
    Result symbolsUpdated(_SymbolUpdated value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (symbolsUpdated != null) {
      return symbolsUpdated(this);
    }
    return orElse();
  }
}

abstract class _SymbolUpdated implements LcdEventType {
  const factory _SymbolUpdated(LcdSymbols symbols) = _$_SymbolUpdated;

  LcdSymbols get symbols;
  _$SymbolUpdatedCopyWith<_SymbolUpdated> get copyWith;
}
