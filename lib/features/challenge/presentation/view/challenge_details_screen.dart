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
    super.key,
  });

  static const _indicatorPadding = EdgeInsets.only(top: 8);

  final String challengeId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsyncValue =
        ref.watch(challengeViewModelProvider(challengeId));
    final challengeViewModel =
        ref.read(challengeViewModelProvider(challengeId).notifier);
    _setupArchiveChallengeListener(challengeViewModel, context, ref);
    useMessageNotifier(context, challengeViewModel);

    return challengeAsyncValue.whenWithData((challenge) {
      final completedChallenges =
          challenge.days.where((day) => day.isCompleted).length;
      final progress = challenge.targetDays > 0
          ? completedChallenges / challenge.targetDays
          : 0.0;

      return Scaffold(
        appBar: AppBar(),
        body: ContentWithBottomSection(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  '''I committed to ${challenge.title} for ${challenge.targetDays} days, starting from ${DateFormat.yMMMd().format(challenge.startDate.toLocal())}.'''
                      .hardcoded,
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
                title: Text('Start over when breaking the streak'.hardcoded),
              ),
              ListTile(
                title: Text('Current streak'.hardcoded),
                subtitle: Text('${challenge.currentStreak} days'),
              ),
              ListTile(
                title: Text('Best streak'.hardcoded),
                subtitle: Text('${challenge.bestStreak} days'),
              ),
              Animate(
                effects: _fadeSlideEffects,
                target: !challenge.startOverEnabled ? 1 : 0,
                autoPlay: false,
                child: ListTile(
                  key: const ValueKey('grace_days'),
                  title: Text('Grace days spent'.hardcoded),
                  trailing: Text(
                    '${challenge.graceDaysSpent}/${ChallengeModel.maxGraceDayCount}'
                        .hardcoded,
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
                  title: Text('Current attempt'.hardcoded),
                  trailing: Text(
                    challenge.numberOfAttempts.toString(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
          bottomSection: Column(
            children: [
              FilledButton.icon(
                onPressed: () =>
                    challengeViewModel.archiveChallengeCommand.execute(),
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text('Archive Challenge'.hardcoded),
              ),
            ],
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
        final subscription = challengeViewModel.archiveChallengeCommand.results
            .listen((result, _) {
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
