import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget {
  const NumberPicker({
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 365,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;

  static Future<int?> show({
    required BuildContext context,
    required int initialValue,
    int minValue = 1,
    int maxValue = 365,
  }) {
    return showAdaptiveBottomSheet<int>(
      context: context,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(context.l10n.selectDays),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () async {
                  final number = await _showEditDialog(
                    context: context,
                    initialValue: initialValue,
                    minValue: minValue,
                    maxValue: maxValue,
                  );
                  if (number != null && context.mounted) {
                    Navigator.pop(context, number);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _NumberPickerDialog(
            initialValue: initialValue,
            minValue: minValue,
            maxValue: maxValue,
          ),
        ],
      ),
    );
  }

  static Future<int?> _showEditDialog({
    required BuildContext context,
    required int initialValue,
    required int minValue,
    required int maxValue,
  }) async {
    final controller = TextEditingController(text: initialValue.toString());
    final formKey = GlobalKey<FormState>();

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.enterDays),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    if (number == null) {
                      return context.l10n.pleaseEnterValidNumber;
                    }
                    if (number < minValue) {
                      return context.l10n.numberMustBeAtLeast(minValue);
                    }
                    if (number > maxValue) {
                      return context.l10n.numberMustBeAtMost(maxValue);
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          OverflowBar(
            alignment: MainAxisAlignment.center,
            overflowAlignment: OverflowBarAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  final number = int.tryParse(controller.text)!;
                  Navigator.pop(context, number);
                },
                child: Text(context.l10n.confirm),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late final FixedExtentScrollController _scrollController;
  static const _itemExtent = 40.0;
  static const _visibleItems = 5;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
      initialItem: widget.value - widget.minValue,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final value = widget.minValue + _scrollController.selectedItem;
    if (value != widget.value) {
      widget.onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: _itemExtent * _visibleItems,
      child: Stack(
        children: [
          ListWheelScrollView(
            controller: _scrollController,
            itemExtent: _itemExtent,
            perspective: 0.0001,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            children: List.generate(
              widget.maxValue - widget.minValue + 1,
              (index) {
                final value = widget.minValue + index;
                final isSelected = value == widget.value;

                return Center(
                  child: Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withCustomOpacity(.5),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                );
              },
            ),
          ),
          // Selection indicator
          Center(
            child: Container(
              height: _itemExtent,
              decoration: BoxDecoration(
                color: color.withCustomOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withCustomOpacity(0.1),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberPickerDialog extends StatefulWidget {
  const _NumberPickerDialog({
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
  });

  final int initialValue;
  final int minValue;
  final int maxValue;

  @override
  State<_NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<_NumberPickerDialog> {
  late int selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumberPicker(
          value: selectedValue,
          minValue: widget.minValue,
          maxValue: widget.maxValue,
          onChanged: (value) => setState(() => selectedValue = value),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.pop(context, selectedValue),
          child: Text(context.l10n.confirm),
        ),
      ],
    );
  }
}
