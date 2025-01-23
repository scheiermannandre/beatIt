sealed class SelectionValue<T, V> {
  const SelectionValue({
    required this.enumValue,
    required this.customValue,
  });

  String get label;
  final T? enumValue;
  final V? customValue;
}

class EnumValue<T extends Enum, V> extends SelectionValue<T, V> {
  const EnumValue({
    required T value,
    required this.labelExtractor,
  }) : super(enumValue: value, customValue: null);

  final String Function(T) labelExtractor;

  @override
  String get label => labelExtractor(enumValue!);
}

class CustomValue<T extends Enum, V> extends SelectionValue<T, V> {
  const CustomValue({
    required V value,
    required this.labelExtractor,
  }) : super(enumValue: null, customValue: value);

  final String Function(V) labelExtractor;

  @override
  String get label => labelExtractor(customValue as V);
}
