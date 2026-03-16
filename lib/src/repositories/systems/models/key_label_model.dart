sealed class KeyLabelModel {
  const KeyLabelModel(this.value);

  factory KeyLabelModel.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;
    final String value = json['value'] as String;
    return switch (type) {
      'text' => KeyLabelModelText(value),
      'icon' => KeyLabelModelIcon(value),
      _ => throw ArgumentError('Unknown KeyLabelModel type: $type'),
    };
  }

  final String value;

  T when<T>({
    required T Function(String value) text,
    required T Function(String value) icon,
  }) =>
      switch (this) {
        KeyLabelModelText() => text(value),
        KeyLabelModelIcon() => icon(value),
      };
}

class KeyLabelModelText extends KeyLabelModel {
  const KeyLabelModelText(super.value);
}

class KeyLabelModelIcon extends KeyLabelModel {
  const KeyLabelModelIcon(super.value);
}
