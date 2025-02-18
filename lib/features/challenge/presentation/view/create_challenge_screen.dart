import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class CreateChallengeScreen extends HookConsumerWidget {
  const CreateChallengeScreen({super.key});

  static const _spacing = 16.0;
  static const _initialDuration = 7;
  static const _maxDurationDays = 365;
  static const _contentPadding = EdgeInsets.symmetric(horizontal: 4);
  static final _dateFormat = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final durationController = useTextEditingController();
    final startDateController = useTextEditingController();
    final duration = useState(_initialDuration);
    final startDate = useState(DateTime.now());
    final startOverEnabled = useState(false);

    final createState = ref.watch(createChallengeViewModelProvider);
    final createViewModel = ref.read(createChallengeViewModelProvider.notifier);
    useMessageNotifier(context, createViewModel);

    _setupCreateChallengeCommandListener(createViewModel, context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.createChallengeTitle),
      ),
      body: ContentWithBottomSection(
        content: Column(
          spacing: _spacing,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StyledTextField(
              controller: titleController,
              label: context.l10n.iCommitToDo,
              context: context,
            ),
            _StyledTextField(
              controller: durationController,
              label: context.l10n.forText,
              readOnly: true,
              focusNode: AlwaysDisabledFocusNode(),
              suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
              context: context,
              onTap: () => pickDuration(context, ref, durationController, duration),
            ),
            _StyledTextField(
              controller: startDateController,
              label: context.l10n.andIWillStartOn,
              readOnly: true,
              focusNode: AlwaysDisabledFocusNode(),
              suffixIcon: const Icon(Icons.keyboard_arrow_right_rounded),
              context: context,
              onTap: () => pickStartDate(context, ref, startDateController, startDate),
            ),
          ],
        ),
        bottomSection: Column(
          children: [
            SwitchListTile(
              value: startOverEnabled.value,
              onChanged: (value) {
                startOverEnabled.value = value;
              },
              title: Text(context.l10n.startOverWhenBreaking),
              contentPadding: _contentPadding,
            ),
            FilledButton(
              onPressed: () => ref.read(createChallengeViewModelProvider.notifier).createChallengeCommand.execute(
                (
                  name: titleController.text,
                  duration: duration.value,
                  startOverEnabled: startOverEnabled.value,
                  startDate: startDate.value,
                ),
              ),
              child: createState.isLoading ? const CircularProgressIndicator() : Text(context.l10n.uiCreateChallenge),
            ),
          ],
        ),
      ),
    );
  }

  void _setupCreateChallengeCommandListener(
    CreateChallengeViewModel createViewModel,
    BuildContext context,
  ) {
    useEffect(
      () {
        createViewModel.createChallengeCommand.results.listen((result, _) {
          if (result.isSuccess) {
            context.pop();
          }
        });

        return null;
      },
      [],
    );
  }

  Future<void> pickDuration(
    BuildContext context,
    WidgetRef ref,
    TextEditingController durationController,
    ValueNotifier<int> duration,
  ) async {
    final result = await showSelectionBottomSheet<ChallengeDuration, int>(
      context: context,
      title: context.l10n.selectDuration,
      values: ChallengeDuration.values,
      labelExtractor: (value) => value.getLabel(context),
      customWidget: ListTile(
        leading: const Icon(Icons.add),
        title: Text(context.l10n.customDuration),
        onTap: () async {
          final navigatorContext = context;

          final selectedDays = await NumberPicker.show(
            context: navigatorContext,
            initialValue: _initialDuration,
          );

          if (selectedDays != null && navigatorContext.mounted) {
            Navigator.pop(
              navigatorContext,
              CustomValue<ChallengeDuration, int>(
                value: selectedDays,
                labelExtractor: (value) => context.l10n.customDurationDays(value),
              ),
            );
          }
        },
      ),
    );

    if (result != null) {
      durationController.text = result.label;
      duration.value = switch (result) {
        EnumValue<ChallengeDuration, int>(enumValue: final v) => v!.amount,
        CustomValue<ChallengeDuration, int>(customValue: final v) => v!,
      };
    }
  }

  Future<void> pickStartDate(
    BuildContext context,
    WidgetRef ref,
    TextEditingController startDateController,
    ValueNotifier<DateTime> startDate,
  ) async {
    final result = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: _maxDurationDays)),
    );

    if (result == null) return;

    startDateController.text = _dateFormat.format(result.toLocal());
    startDate.value = result;
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class _StyledTextField extends TextField {
  _StyledTextField({
    required super.controller,
    required String label,
    required BuildContext context,
    super.onTap,
    super.readOnly,
    super.focusNode,
    Widget? suffixIcon,
  }) : super(
          decoration: InputDecoration(
            label: Text(label),
            floatingLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: _fontSize),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: _focusBorderWidth,
              ),
            ),
            contentPadding: _padding,
            suffixIcon: suffixIcon,
          ),
        );

  static const _fontSize = 24.0;
  static const _borderRadius = 8.0;
  static const _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const _focusBorderWidth = 2.0;
}
