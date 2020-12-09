// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'key_label_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
KeyLabelModel _$KeyLabelModelFromJson(Map<String, dynamic> json) {
  switch (json['type'] as String) {
    case 'text':
      return KeyLabelModelText.fromJson(json);
    case 'icon':
      return KeyLabelModelIcon.fromJson(json);

    default:
      throw FallThroughError();
  }
}

/// @nodoc
class _$KeyLabelModelTearOff {
  const _$KeyLabelModelTearOff();

// ignore: unused_element
  KeyLabelModelText text(String value) {
    return KeyLabelModelText(
      value,
    );
  }

// ignore: unused_element
  KeyLabelModelIcon icon(String value) {
    return KeyLabelModelIcon(
      value,
    );
  }

// ignore: unused_element
  KeyLabelModel fromJson(Map<String, Object> json) {
    return KeyLabelModel.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $KeyLabelModel = _$KeyLabelModelTearOff();

/// @nodoc
mixin _$KeyLabelModel {
  String get value;

  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult text(String value),
    @required TResult icon(String value),
  });
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult text(String value),
    TResult icon(String value),
    @required TResult orElse(),
  });
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult text(KeyLabelModelText value),
    @required TResult icon(KeyLabelModelIcon value),
  });
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult text(KeyLabelModelText value),
    TResult icon(KeyLabelModelIcon value),
    @required TResult orElse(),
  });
  Map<String, dynamic> toJson();
  $KeyLabelModelCopyWith<KeyLabelModel> get copyWith;
}

/// @nodoc
abstract class $KeyLabelModelCopyWith<$Res> {
  factory $KeyLabelModelCopyWith(
          KeyLabelModel value, $Res Function(KeyLabelModel) then) =
      _$KeyLabelModelCopyWithImpl<$Res>;
  $Res call({String value});
}

/// @nodoc
class _$KeyLabelModelCopyWithImpl<$Res>
    implements $KeyLabelModelCopyWith<$Res> {
  _$KeyLabelModelCopyWithImpl(this._value, this._then);

  final KeyLabelModel _value;
  // ignore: unused_field
  final $Res Function(KeyLabelModel) _then;

  @override
  $Res call({
    Object value = freezed,
  }) {
    return _then(_value.copyWith(
      value: value == freezed ? _value.value : value as String,
    ));
  }
}

/// @nodoc
abstract class $KeyLabelModelTextCopyWith<$Res>
    implements $KeyLabelModelCopyWith<$Res> {
  factory $KeyLabelModelTextCopyWith(
          KeyLabelModelText value, $Res Function(KeyLabelModelText) then) =
      _$KeyLabelModelTextCopyWithImpl<$Res>;
  @override
  $Res call({String value});
}

/// @nodoc
class _$KeyLabelModelTextCopyWithImpl<$Res>
    extends _$KeyLabelModelCopyWithImpl<$Res>
    implements $KeyLabelModelTextCopyWith<$Res> {
  _$KeyLabelModelTextCopyWithImpl(
      KeyLabelModelText _value, $Res Function(KeyLabelModelText) _then)
      : super(_value, (v) => _then(v as KeyLabelModelText));

  @override
  KeyLabelModelText get _value => super._value as KeyLabelModelText;

  @override
  $Res call({
    Object value = freezed,
  }) {
    return _then(KeyLabelModelText(
      value == freezed ? _value.value : value as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$KeyLabelModelText
    with DiagnosticableTreeMixin
    implements KeyLabelModelText {
  const _$KeyLabelModelText(this.value) : assert(value != null);

  factory _$KeyLabelModelText.fromJson(Map<String, dynamic> json) =>
      _$_$KeyLabelModelTextFromJson(json);

  @override
  final String value;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'KeyLabelModel.text(value: $value)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'KeyLabelModel.text'))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is KeyLabelModelText &&
            (identical(other.value, value) ||
                const DeepCollectionEquality().equals(other.value, value)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(value);

  @override
  $KeyLabelModelTextCopyWith<KeyLabelModelText> get copyWith =>
      _$KeyLabelModelTextCopyWithImpl<KeyLabelModelText>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult text(String value),
    @required TResult icon(String value),
  }) {
    assert(text != null);
    assert(icon != null);
    return text(value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult text(String value),
    TResult icon(String value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (text != null) {
      return text(value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult text(KeyLabelModelText value),
    @required TResult icon(KeyLabelModelIcon value),
  }) {
    assert(text != null);
    assert(icon != null);
    return text(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult text(KeyLabelModelText value),
    TResult icon(KeyLabelModelIcon value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (text != null) {
      return text(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$_$KeyLabelModelTextToJson(this)..['type'] = 'text';
  }
}

abstract class KeyLabelModelText implements KeyLabelModel {
  const factory KeyLabelModelText(String value) = _$KeyLabelModelText;

  factory KeyLabelModelText.fromJson(Map<String, dynamic> json) =
      _$KeyLabelModelText.fromJson;

  @override
  String get value;
  @override
  $KeyLabelModelTextCopyWith<KeyLabelModelText> get copyWith;
}

/// @nodoc
abstract class $KeyLabelModelIconCopyWith<$Res>
    implements $KeyLabelModelCopyWith<$Res> {
  factory $KeyLabelModelIconCopyWith(
          KeyLabelModelIcon value, $Res Function(KeyLabelModelIcon) then) =
      _$KeyLabelModelIconCopyWithImpl<$Res>;
  @override
  $Res call({String value});
}

/// @nodoc
class _$KeyLabelModelIconCopyWithImpl<$Res>
    extends _$KeyLabelModelCopyWithImpl<$Res>
    implements $KeyLabelModelIconCopyWith<$Res> {
  _$KeyLabelModelIconCopyWithImpl(
      KeyLabelModelIcon _value, $Res Function(KeyLabelModelIcon) _then)
      : super(_value, (v) => _then(v as KeyLabelModelIcon));

  @override
  KeyLabelModelIcon get _value => super._value as KeyLabelModelIcon;

  @override
  $Res call({
    Object value = freezed,
  }) {
    return _then(KeyLabelModelIcon(
      value == freezed ? _value.value : value as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$KeyLabelModelIcon
    with DiagnosticableTreeMixin
    implements KeyLabelModelIcon {
  const _$KeyLabelModelIcon(this.value) : assert(value != null);

  factory _$KeyLabelModelIcon.fromJson(Map<String, dynamic> json) =>
      _$_$KeyLabelModelIconFromJson(json);

  @override
  final String value;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'KeyLabelModel.icon(value: $value)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'KeyLabelModel.icon'))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is KeyLabelModelIcon &&
            (identical(other.value, value) ||
                const DeepCollectionEquality().equals(other.value, value)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(value);

  @override
  $KeyLabelModelIconCopyWith<KeyLabelModelIcon> get copyWith =>
      _$KeyLabelModelIconCopyWithImpl<KeyLabelModelIcon>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult text(String value),
    @required TResult icon(String value),
  }) {
    assert(text != null);
    assert(icon != null);
    return icon(value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult text(String value),
    TResult icon(String value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (icon != null) {
      return icon(value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult text(KeyLabelModelText value),
    @required TResult icon(KeyLabelModelIcon value),
  }) {
    assert(text != null);
    assert(icon != null);
    return icon(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult text(KeyLabelModelText value),
    TResult icon(KeyLabelModelIcon value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (icon != null) {
      return icon(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$_$KeyLabelModelIconToJson(this)..['type'] = 'icon';
  }
}

abstract class KeyLabelModelIcon implements KeyLabelModel {
  const factory KeyLabelModelIcon(String value) = _$KeyLabelModelIcon;

  factory KeyLabelModelIcon.fromJson(Map<String, dynamic> json) =
      _$KeyLabelModelIcon.fromJson;

  @override
  String get value;
  @override
  $KeyLabelModelIconCopyWith<KeyLabelModelIcon> get copyWith;
}
