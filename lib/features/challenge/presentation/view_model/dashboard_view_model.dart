import 'dart:async';

import 'package:beat_it/features/challenge/challenge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_view_model.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  late final StreamSubscription<List<ChallengeModel>> _subscription;

  @override
  FutureOr<List<ChallengeModel>> build() {
    final repository = ref.watch(challengeRepositoryProvider);

    _subscription = repository.observeChallenges().listen(updateChallenges);

    ref.onDispose(() {
      _subscription.cancel();
    });

    return _getChallenges();
  }

  void updateChallenges(List<ChallengeModel> challenges) {
    state = AsyncData(challenges);
  }

  Future<List<ChallengeModel>> _getChallenges() async {
    final repository = ref.read(challengeRepositoryProvider);
    final result = await repository.getChallenges();

    return result.fold(
      (data) => data,
      (error) => throw error,
    );
  }

  Future<void> analyzeChallenges() async {
    final repository = ref.read(challengeRepositoryProvider);
    await repository.checkNeedToBreakChallenges();
    await repository.checkNeedToArchiveChallenge();
  }
}
