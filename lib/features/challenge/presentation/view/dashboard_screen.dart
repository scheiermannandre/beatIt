import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DashboardScreen extends StatefulHookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  static const _animationConfig = (
    fadeInDuration: Duration(milliseconds: 500),
    slideBegin: Offset(0.5, 0),
    shimmerDuration: Duration(milliseconds: 750),
  );

  static const _listPadding =
      EdgeInsets.only(top: 8, bottom: 24, left: 8, right: 8);
  static const _itemSpacing = 8.0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref
          .read(uncheckedChallengesAnalyzerProvider.notifier)
          .shouldCheckChallenges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final challengesAsyncValue = ref.watch(dashboardViewModelProvider);

    _setupUncheckedChallengesListener(
      ref: ref,
      context: context,
      challengesAsyncValue: challengesAsyncValue,
    );
    _setupNewItemsListener(ref: ref, scrollController: scrollController);

    return Scaffold(
      appBar: AppBar(
        title: Text('Beat It'.hardcoded),
        actions: [
          IconButton(
            onPressed: () => context.pushCreateChallenge(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: challengesAsyncValue.when(
        data: (challenges) => challenges.when(
          empty: () {
            return NoChallenges(
              onCreateChallenge: () => context.pushCreateChallenge(),
            );
          },
          notEmpty: (challenges) {
            return ListView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              padding: _listPadding,
              children: AnimateList(
                effects: [
                  FadeEffect(duration: _animationConfig.fadeInDuration),
                  SlideEffect(
                    begin: _animationConfig.slideBegin,
                    curve: Curves.easeOutQuad,
                    duration: _animationConfig.fadeInDuration,
                  ),
                  const ThenEffect(),
                  ShimmerEffect(
                    duration: _animationConfig.shimmerDuration,
                  ),
                ],
                children: challenges
                    .map(
                      (challenge) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: _itemSpacing / 2,
                        ),
                        child: ChallengeWidget(
                          key: ValueKey(challenge.id),
                          challengeId: challenge.id,
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _setupNewItemsListener({
    required WidgetRef ref,
    required ScrollController scrollController,
  }) {
    ref.listen(dashboardViewModelProvider, (previousAsyncValue, newAsyncValue) {
      final previousValue = previousAsyncValue?.valueOrNull;
      final newValue = newAsyncValue.valueOrNull;

      if (previousValue == null || newValue == null) return;
      if (previousValue.length >= newValue.length) return;

      if (!scrollController.hasClients) return;
      Future.delayed(const Duration(milliseconds: 50), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController
              .jumpTo(scrollController.position.maxScrollExtent + 100);
        });
      });
    });
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
