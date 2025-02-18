import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UncheckedChallengesBottomSheet extends HookConsumerWidget {
  const UncheckedChallengesBottomSheet._({
    required this.uncheckedChallenges,
  });

  final List<ChallengeModel> uncheckedChallenges;
  static const _spacing = 8.0;
  static const _warnDialogSpacing = 16.0;
  static const _contentPadding = EdgeInsets.only(
    left: 16,
    right: 8,
    top: 4,
    bottom: 4,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.now().subtract(const Duration(days: 1));
    ref.watch(uncheckedChallengesBottomSheetViewModelProvider);
    final viewModel = ref.watch(uncheckedChallengesBottomSheetViewModelProvider.notifier);
    _setupCommandListeners(viewModel, context);
    final isCheckLoading = useState(false);
    useMessageNotifier(context, viewModel);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: _spacing,
      children: [
        ...uncheckedChallenges.map(
          (challenge) => Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: _contentPadding,
              title: Text(challenge.title),
              trailing: CheckButton(
                challengeId: challenge.id,
                date: date,
                isLoading: isCheckLoading,
              ),
            ),
          ),
        ),
        Button.text(
          onPressed: !viewModel.checkChallengesCommand.isExecuting.value && !isCheckLoading.value
              ? () async => closeClicked(ref, context, viewModel)
              : null,
          isLoading: viewModel.closeCommand.isExecuting.value,
          child: Text(context.l10n.close),
        ),
        Button.primary(
          onPressed: !viewModel.closeCommand.isExecuting.value && !isCheckLoading.value
              ? () => viewModel.checkChallengesCommand.execute(uncheckedChallenges)
              : null,
          isLoading: viewModel.checkChallengesCommand.isExecuting.value,
          child: Text(context.l10n.checkAll),
        ),
      ],
    );
  }

  Future<void> closeClicked(
    WidgetRef ref,
    BuildContext context,
    UncheckedChallengesBottomSheetViewModel viewModel,
  ) async {
    final challenges = await ref.read(currentChallengesViewModelProvider.future);
    final stillUncheckedChallenges = _getUncheckedYesterdayChallenges(
      challenges,
    );
    if (stillUncheckedChallenges.isNotEmpty) {
      final continueResult =
          // ignore: use_build_context_synchronously
          await showWarning(context, stillUncheckedChallenges);
      if (continueResult ?? false) {
        viewModel.closeCommand.execute(stillUncheckedChallenges);
      }
    }
  }

  Future<bool?> showWarning(
    BuildContext context,
    List<ChallengeModel> stillUncheckedChallenges,
  ) async {
    return showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.l10n.uncheckedChallengesWarningTitle(
            stillUncheckedChallenges.length,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: _warnDialogSpacing,
            children: [
              Text(
                context.l10n.uncheckedChallengesWarningMessage,
                textAlign: TextAlign.center,
              ),
              Text(
                context.l10n.uncheckedChallengesWarningQuestion,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.continueText),
          ),
        ],
      ),
    );
  }

  void _setupCommandListeners(
    UncheckedChallengesBottomSheetViewModel viewModel,
    BuildContext context,
  ) {
    useEffect(
      () {
        viewModel.checkChallengesCommand.results.listen((result, _) {
          if (result.data ?? false) {
            Navigator.of(context).pop();
          }
        });
        viewModel.closeCommand.results.listen((result, _) {
          if (result.data ?? false) {
            Navigator.of(context).pop();
          }
        });
        return null;
      },
      [],
    );
  }

  static void showIfNeeded({
    required BuildContext context,
    required List<ChallengeModel> challenges,
  }) {
    final uncheckedChallenges = _getUncheckedYesterdayChallenges(challenges);
    if (uncheckedChallenges.isNotEmpty) {
      showAdaptiveBottomSheet<void>(
        context: context,
        isDismissible: false,
        title: Text(context.l10n.uncheckedChallengesTitle),
        child: UncheckedChallengesBottomSheet._(
          uncheckedChallenges: uncheckedChallenges,
        ),
      );
    }
  }

  static List<ChallengeModel> _getUncheckedYesterdayChallenges(
    List<ChallengeModel> challenges,
  ) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    return challenges.where((challenge) {
      final wasActive = yesterday.isAfter(challenge.startDate) &&
          yesterday.isBefore(
            challenge.startDate.add(Duration(days: challenge.targetDays)),
          );

      if (!wasActive) return false;

      final yesterdayDay = challenge.days.firstWhere(
        (day) => day.date.year == yesterday.year && day.date.month == yesterday.month && day.date.day == yesterday.day,
        orElse: () => DayModel(date: yesterday, status: DayStatus.none),
      );

      return yesterdayDay.isNone;
    }).toList();
  }
}
