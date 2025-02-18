import 'dart:async';

import 'package:beat_it/features/challenge/challenge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'archived_challenges_view_model.g.dart';

@riverpod
class ArchivedChallengesViewModel extends _$ArchivedChallengesViewModel {
  late final StreamSubscription<List<ChallengeModel>> _subscription;

  @override
  FutureOr<List<ChallengeModel>> build() {
    final repository = ref.watch(challengeRepositoryProvider);

    _subscription = repository.observeArchivedChallenges().listen(updateChallenges);

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
    final result = await repository.getArchivedChallenges();

    return result.fold(
      (data) => data,
      (error) => throw error,
    );
  }
}
