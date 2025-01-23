import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueExtension<T> on AsyncValue<T> {
  Widget whenWithData(Widget Function(T) builder) {
    if (hasValue) {
      return builder(value as T);
    }
    return customWhen(  builder );
  }

  Widget customWhen(Widget Function(T) builder) {
    return when(
      data: builder,
      error: (_, __) => const Center(child: Text('Error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
