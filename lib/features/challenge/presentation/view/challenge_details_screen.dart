import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

const _fadeSlideEffects = <Effect<void>>[
  VisibilityEffect(duration: Duration.zero),
  ThenEffect(),
  FadeEffect(duration: Duration(milliseconds: 300)),
  SlideEffect(begin: Offset(0, 0.3), duration: Duration(milliseconds: 300)),
  SizeEffect(duration: Duration(milliseconds: 300)),
];

class ChallengeDetailsScreen extends HookConsumerWidget {
  const ChallengeDetailsScreen({
    required this.challengeId,
    required this.isArchived,
    super.key,
  });

  static const _indicatorPadding = EdgeInsets.only(top: 8);

  final String challengeId;
  final bool isArchived;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsyncValue = ref.watch(challengeViewModelProvider(challengeId));
    final challengeViewModel = ref.read(challengeViewModelProvider(challengeId).notifier);
    _setupArchiveChallengeListener(challengeViewModel, context, ref);
    useMessageNotifier(context, challengeViewModel);

    return challengeAsyncValue.whenWithData((challenge) {
      final completedChallenges = challenge.days.where((day) => day.isCompleted).length;
      final progress = challenge.targetDays > 0 ? completedChallenges / challenge.targetDays : 0.0;

      return Scaffold(
        appBar: AppBar(),
        body: IgnorePointer(
          ignoring: isArchived,
          child: ContentWithBottomSection(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    context.l10n.challengeCommitmentText(
                      challenge.title,
                      challenge.targetDays,
                      DateFormat.yMMMd().format(challenge.startDate.toLocal()),
                    ),
                  ),
                  subtitle: Padding(
                    padding: _indicatorPadding,
                    child: AnimatedProgressIndicator(
                      progress: progress,
                      challengeId: challengeId,
                    ),
                  ),
                ),
                SwitchListTile(
                  value: challenge.startOverEnabled,
                  onChanged: (value) => challengeViewModel.enableStartOver(
                    challengeId: challengeId,
                    enable: value,
                  ),
                  title: Text(context.l10n.startOverWhenBreaking),
                ),
                ListTile(
                  title: Text(context.l10n.currentStreakTitle),
                  subtitle: Text(context.l10n.streak(challenge.currentStreak)),
                ),
                ListTile(
                  title: Text(context.l10n.bestStreakTitle),
                  subtitle: Text(context.l10n.streak(challenge.bestStreak)),
                ),
                Animate(
                  effects: _fadeSlideEffects,
                  target: !challenge.startOverEnabled ? 1 : 0,
                  autoPlay: false,
                  child: ListTile(
                    key: const ValueKey('grace_days'),
                    title: Text(context.l10n.graceDaysSpent),
                    trailing: Text(
                      context.l10n.graceDaysCount(
                        challenge.graceDaysSpent,
                        ChallengeModel.maxGraceDayCount,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                Animate(
                  effects: _fadeSlideEffects,
                  target: challenge.startOverEnabled ? 1 : 0,
                  autoPlay: false,
                  child: ListTile(
                    key: const ValueKey('current_attempt'),
                    title: Text(context.l10n.currentAttempt),
                    trailing: Text(
                      '${challenge.numberOfAttempts}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            bottomSection: Column(
              children: [
                Visibility(
                  visible: !isArchived,
                  child: FilledButton.icon(
                    onPressed: () => challengeViewModel.archiveChallengeCommand.execute(),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(context.l10n.archiveChallenge),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _setupArchiveChallengeListener(
    ChallengeViewModel challengeViewModel,
    BuildContext context,
    WidgetRef ref,
  ) {
    useEffect(
      () {
        final subscription = challengeViewModel.archiveChallengeCommand.results.listen((result, _) {
          if (result.data?.isSuccess() ?? false) {
            context.pop();
          }
        });
        return subscription.cancel;
      },
      [],
    );
  }
}
