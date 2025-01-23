extension IterableX<T> on Iterable<T> {
  R when<R>({
    required R Function() empty,
    required R Function(Iterable<T> items) notEmpty,
  }) {
    if (isEmpty) {
      return empty();
    }
    return notEmpty(this);
  }

  T? getAtIndexOrNull(int index) {
    if (index >= length) return null;
    return elementAt(index);
  }
}
