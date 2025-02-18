import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/features/challenge/presentation/widgets/no_challenges_in_tab.dart';
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

    return challengesAsyncValue.when(
      data: (challenges) => challenges.when(
        empty: () => NoChallengesInTab(title: context.l10n.uiNoChallenges),
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
}
