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
  _DisplayBufferUpdated displayBufferUpdated(int address, int value) {
    return _DisplayBufferUpdated(
      address,
      value,
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
    @required Result displayBufferUpdated(int address, int value),
    @required Result symbolsUpdated(LcdSymbols symbols),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result displayBufferUpdated(int address, int value),
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
  $Res call({int address, int value});
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
    Object address = freezed,
    Object value = freezed,
  }) {
    return _then(_DisplayBufferUpdated(
      address == freezed ? _value.address : address as int,
      value == freezed ? _value.value : value as int,
    ));
  }
}

/// @nodoc
class _$_DisplayBufferUpdated implements _DisplayBufferUpdated {
  const _$_DisplayBufferUpdated(this.address, this.value)
      : assert(address != null),
        assert(value != null);

  @override
  final int address;
  @override
  final int value;

  @override
  String toString() {
    return 'LcdEventType.displayBufferUpdated(address: $address, value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _DisplayBufferUpdated &&
            (identical(other.address, address) ||
                const DeepCollectionEquality()
                    .equals(other.address, address)) &&
            (identical(other.value, value) ||
                const DeepCollectionEquality().equals(other.value, value)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(address) ^
      const DeepCollectionEquality().hash(value);

  @override
  _$DisplayBufferUpdatedCopyWith<_DisplayBufferUpdated> get copyWith =>
      __$DisplayBufferUpdatedCopyWithImpl<_DisplayBufferUpdated>(
          this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result displayBufferUpdated(int address, int value),
    @required Result symbolsUpdated(LcdSymbols symbols),
  }) {
    assert(displayBufferUpdated != null);
    assert(symbolsUpdated != null);
    return displayBufferUpdated(address, value);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result displayBufferUpdated(int address, int value),
    Result symbolsUpdated(LcdSymbols symbols),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (displayBufferUpdated != null) {
      return displayBufferUpdated(address, value);
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
  const factory _DisplayBufferUpdated(int address, int value) =
      _$_DisplayBufferUpdated;

  int get address;
  int get value;
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
    @required Result displayBufferUpdated(int address, int value),
    @required Result symbolsUpdated(LcdSymbols symbols),
  }) {
    assert(displayBufferUpdated != null);
    assert(symbolsUpdated != null);
    return symbolsUpdated(symbols);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result displayBufferUpdated(int address, int value),
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
