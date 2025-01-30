import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';

Future<SelectionValue<T, V>?> showSelectionBottomSheet<T extends Enum, V>({
  required BuildContext context,
  required String title,
  required List<T> values,
  required String Function(T) labelExtractor,
  Widget? customWidget,
}) {
  return showAdaptiveBottomSheet<SelectionValue<T, V>>(
    context: context,
    title: Text(title),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...values.map(
          (value) => ListTile(
            title: Text(labelExtractor(value)),
            onTap: () => Navigator.pop(
              context,
              EnumValue<T, V>(
                value: value,
                labelExtractor: labelExtractor,
              ),
            ),
          ),
        ),
        if (customWidget != null) ...[
          const Divider(),
          customWidget,
        ],
      ],
    ),
  );
}
