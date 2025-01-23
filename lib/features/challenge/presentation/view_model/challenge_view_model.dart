import 'dart:async';

import 'package:beat_it/core/providers/app_message_provider.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/lib.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_view_model.g.dart';

@riverpod
class ChallengeViewModel extends _$ChallengeViewModel {
  late final ChallengeRepository _repository;
  late final AppMessageManager _appMessageManager;
  late final StreamSubscription<ChallengeModel?> _subscription;
  late final Command<void, Result<Unit>> archiveChallengeCommand;
  late final Command<void, Result<Unit>> checkChallengeCommand;
  @override
  FutureOr<ChallengeModel> build(String challengeId) async {
    _repository = ref.read(challengeRepositoryProvider);
    _appMessageManager = ref.read(appMessageManagerProvider);

    checkChallengeCommand = Command.createAsync<DateTime, Result<Unit>>(
      (date) => checkChallengeForDate(challengeId: challengeId, date: date),
      initialValue: const Success(unit),
    );

    archiveChallengeCommand = Command.createAsyncNoParam<Result<Unit>>(
      () => archiveChallenge(challengeId),
      initialValue: const Success(unit),
    );

    _subscription = _repository
        .observeChallengeById(challengeId)
        .listen((challenge) => state = AsyncData(challenge));

    ref.onDispose(() {
      _subscription.cancel();
    });

    return await getChallenge(challengeId);
  }

  Future<ChallengeModel> getChallenge(String challengeId) async {
    final challengeResult = await _repository.getChallengeById(challengeId);
    //state = AsyncData(challengeResult.getOrNull());
    return challengeResult.fold(
      (challenge) => challenge,
      (error) => throw Exception('Failed to get challenge'),
    );
  }

  AsyncResult<Unit> checkChallengeForDate({
    required String challengeId,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    final result = await _repository.checkChallengeForDate(
      challengeId: challengeId,
      date: date,
    );

    state = result.fold(
      AsyncData.new,
      (failure) => AsyncError(failure, StackTrace.current),
    );

    if (state is AsyncData) {
      return const Success(unit);
    }
    final message = 'Failed to check challenge for date'.hardcoded;
    _appMessageManager.showError(message);
    return Failure(Exception(message));
  }

  AsyncResult<Unit> enableStartOver({
    required String challengeId,
    required bool enable,
  }) async {
    final result = await _repository.enableStartOver(
      challengeId: challengeId,
      enable: enable,
    );
    return result;
  }

  AsyncResult<Unit> archiveChallenge(String challengeId) async {
    final result = await _repository.archiveChallenge(
      challengeId: challengeId,
    );
    if (result.isSuccess()) {
      await _subscription.cancel();
    }
    return result;
  }
}
