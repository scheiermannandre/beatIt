import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CurrentChallengesTab extends HookConsumerWidget {
  const CurrentChallengesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final challengesAsyncValue = ref.watch(currentChallengesViewModelProvider);

    _setupUncheckedChallengesListener(
      ref: ref,
      context: context,
      challengesAsyncValue: challengesAsyncValue,
    );

    return challengesAsyncValue.when(
      data: (challenges) => challenges.when(
        empty: () {
          return NoChallenges(
            onCreateChallenge: () => context.pushCreateChallenge(),
          );
        },
        notEmpty: (challenges) {
          return ChallengesList(
            challenges: challenges.toList(),
            scrollController: scrollController,
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }

  void _setupUncheckedChallengesListener({
    required WidgetRef ref,
    required BuildContext context,
    required AsyncValue<List<ChallengeModel>> challengesAsyncValue,
  }) {
    ref.listen(
      uncheckedChallengesAnalyzerProvider,
      (_, shouldCheck) {
        if (!shouldCheck || !challengesAsyncValue.hasValue) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          UncheckedChallengesBottomSheet.showIfNeeded(
            context: context,
            challenges: challengesAsyncValue.value!,
          );
        });
      },
    );
  }
}
