import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/features/challenge/presentation/view/tabs/archived_challenges_tab.dart';
import 'package:beat_it/features/challenge/presentation/view/tabs/current_challenges_tab.dart';
import 'package:beat_it/features/challenge/presentation/view/tabs/future_challenges_tab.dart';
import 'package:beat_it/features/challenge/presentation/view_model/dashboard_view_model.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _listPadding = EdgeInsets.only(top: 8, bottom: 24, left: 8, right: 8);
const _itemSpacing = 8.0;
const _animationConfig = (
  fadeInDuration: Duration(milliseconds: 500),
  slideBegin: Offset(0.5, 0),
  shimmerDuration: Duration(milliseconds: 750),
);

class DashboardScreen extends StatefulHookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await ref.read(dashboardViewModelProvider.notifier).analyzeChallenges();
      ref.read(uncheckedChallengesAnalyzerProvider.notifier).shouldCheckChallenges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final challengesAsyncValue = ref.watch(dashboardViewModelProvider);

    _setupUncheckedChallengesListener(
      ref: ref,
      context: context,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () => context.pushCreateChallenge(),
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: challengesAsyncValue.when(
          data: (challenges) => challenges.isNotEmpty
              ? TabBar(
                  dividerColor: Colors.transparent,
                  controller: _tabController,
                  tabs: [
                    Tab(text: context.l10n.tabArchived),
                    Tab(text: context.l10n.tabCurrent),
                    Tab(text: context.l10n.tabFuture),
                  ],
                )
              : null,
          loading: () => null,
          error: (error, stackTrace) => null,
        ),
      ),
      body: challengesAsyncValue.when(
        data: (challenges) => challenges.when(
          empty: () {
            return NoChallenges(
              onCreateChallenge: () => context.pushCreateChallenge(),
            );
          },
          notEmpty: (challenges) {
            return TabBarView(
              controller: _tabController,
              children: const [
                ArchivedChallengesTab(),
                CurrentChallengesTab(),
                FutureChallengesTab(),
              ],
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _setupUncheckedChallengesListener({
    required WidgetRef ref,
    required BuildContext context,
  }) {
    ref.listen(
      uncheckedChallengesAnalyzerProvider,
      (_, shouldCheck) async {
        final challengesResult = await ref.read(challengeRepositoryProvider).getCurrentChallenges();
        if (challengesResult.isError()) return;
        final challenges = challengesResult.getOrThrow();
        if (!shouldCheck || challenges.isEmpty) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          UncheckedChallengesBottomSheet.showIfNeeded(
            context: context,
            challenges: challenges.where((challenge) => !(challenge.isArchived ?? false)).toList(),
          );
        });
      },
    );
  }
}

class ChallengesList extends StatelessWidget {
  const ChallengesList({
    required this.challenges,
    required this.scrollController,
    super.key,
  });

  final List<ChallengeModel> challenges;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return Center(
        child: Text(
          'No challenges',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

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
  }
}
