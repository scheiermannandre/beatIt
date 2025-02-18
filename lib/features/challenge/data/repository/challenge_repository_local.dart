import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_repository_local.g.dart';

class ChallengeRepositoryLocal extends ChallengeRepository {
  ChallengeRepositoryLocal(this._service);

  final ChallengeServiceLocal _service;

  /// Fetches all challenges, sorts them by creation date,
  /// and updates the cache.
  @override
  AsyncResult<List<ChallengeModel>> getChallenges() async {
    final result = await _service.getChallenges();
    if (result.isError()) {
      return Failure(result.exceptionOrNull()!);
    }

    final challenges = result.getOrThrow()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    updateCacheInBatch(challenges);
    return Success(challenges);
  }

  /// Fetches all current challenges, sorts them by creation date,
  /// and updates the cache.
  @override
  AsyncResult<List<ChallengeModel>> getCurrentChallenges() async {
    final result = await getChallenges();
    if (result.isError()) return result;

    final challenges = result.getOrThrow();
    final currentChallenges = challenges
        .where(
          (c) => c.startDate.withoutTime.isBeforeOrAt(DateTime.now().withoutTime) && !(c.isArchived ?? false),
        )
        .toList();

    return Success(currentChallenges);
  }

  /// Fetches all future challenges, sorts them by creation date,
  /// and updates the cache.
  @override
  AsyncResult<List<ChallengeModel>> getFutureChallenges() async {
    final result = await getChallenges();
    if (result.isError()) return result;

    final challenges = result.getOrThrow();
    final futureChallenges = challenges
        .where(
          (c) => c.startDate.withoutTime.isAfter(DateTime.now().withoutTime) && !(c.isArchived ?? false),
        )
        .toList();

    return Success(futureChallenges);
  }

  /// Fetches all archived challenges, sorts them by creation date,
  /// and updates the cache.
  @override
  AsyncResult<List<ChallengeModel>> getArchivedChallenges() async {
    final result = await getChallenges();
    if (result.isError()) return result;

    final challenges = result.getOrThrow();
    final archivedChallenges = challenges.where((c) => c.isArchived ?? false).toList();

    return Success(archivedChallenges);
  }

  /// Checks or unchecks a challenge for a specific date.
  /// Returns failure if date is outside challenge period.
  @override
  AsyncResult<ChallengeModel> checkChallengeForDate({
    required String challengeId,
    required DateTime date,
  }) async {
    final challengeResult = await getChallengeById(challengeId);
    if (challengeResult.isError()) return challengeResult;

    final currentChallenge = challengeResult.getOrThrow();
    if (!_isDateWithinChallengePeriod(date, currentChallenge)) {
      return const Failure(ChallengeException.dateOutsideChallengePeriod());
    }

    final updatedChallenge = _updateChallengeDay(currentChallenge, date);
    final updateResult = await _service.updateChallenge(updatedChallenge);

    if (updateResult.isSuccess()) {
      updateCache(challengeId, updateResult.getOrThrow());
    }
    return updateResult;
  }

  /// Creates a new challenge and caches it.
  @override
  AsyncResult<Unit> createChallenge({
    required ChallengeModel challenge,
  }) async {
    if (challenge.targetDays <= 0) {
      return const Failure(ChallengeException.invalidDuration());
    }
    final result = await _service.createChallenge(challenge);
    if (result.isSuccess()) {
      updateCache(challenge.id, result.getOrThrow());
      return const Success(unit);
    }
    return Failure(result.exceptionOrNull()!);
  }

  /// Toggles start over functionality for a challenge.
  /// When enabled, challenge resets on streak break.
  @override
  AsyncResult<Unit> enableStartOver({
    required String challengeId,
    required bool enable,
  }) async {
    final challengeResult = await getChallengeById(challengeId);
    if (challengeResult.isError()) {
      return Failure(challengeResult.exceptionOrNull()!);
    }

    final challenge = challengeResult.getOrThrow();
    final updatedChallenge = challenge.copyWith(startOverEnabled: enable);
    return _updateAndCache(updatedChallenge, challengeId);
  }

  /// Archives a challenge and removes it from active cache.
  // @override
  // AsyncResult<Unit> archiveChallenge({
  //   required String challengeId,
  // }) async {
  //   final result = await _service.archiveChallenge(challengeId);
  //   if (result.isSuccess()) {
  //     deleteFromCache(challengeId);
  //     return const Success(unit);
  //   }
  //   return Failure(result.exceptionOrNull()!);
  // }

  /// Checks if yesterday's challenge was missed and handles accordingly:
  /// - If start over enabled: Resets challenge
  /// - If disabled: Extends duration and marks as skipped
  /// - If grace days spent: Deletes challenge
  @override
  AsyncResult<Unit> breakChallengeIfNeeded({
    required String challengeId,
  }) async {
    final challengeResult = await getChallengeById(challengeId);
    if (challengeResult.isError()) {
      return Failure(challengeResult.exceptionOrNull()!);
    }

    final challenge = challengeResult.getOrThrow();
    if (challenge.isYesterdayCompleted || challenge.isYesterdaySkipped) {
      return const Success(unit);
    }

    final updatedChallenge =
        challenge.startOverEnabled ? _handleStartOver(challenge) : _handleExtendChallenge(challenge);

    if (updatedChallenge.areGraceDaysSpent) {
      return archiveChallenge(challengeId: challengeId);
    }

    return _updateAndCache(updatedChallenge, challengeId);
  }

  /// Updates a challenge day's status, toggling between completed and none.
  /// If the day doesn't exist, adds it as completed.
  /// Returns updated challenge with sorted days and
  /// updated last completion date.
  ChallengeModel _updateChallengeDay(ChallengeModel challenge, DateTime date) {
    final dayIndex = challenge.days.indexWhere(
      (day) => day.date.isSameDay(date),
    );

    List<DayModel> updatedDays;
    if (dayIndex == -1) {
      updatedDays = [
        ...challenge.days,
        DayModel(date: date, status: DayStatus.completed),
      ]..sort((a, b) => a.date.compareTo(b.date));
    } else {
      updatedDays = List.from(challenge.days);
      updatedDays[dayIndex] = challenge.days[dayIndex].copyWith(
        status: _toggleDayStatus(challenge.days[dayIndex].status),
      );
    }

    return challenge.copyWith(
      days: updatedDays,
      lastCompletedDate: updatedDays.any((d) => d.isCompleted) ? date : null,
    );
  }

  /// Resets the challenge by clearing all days and setting start date to now.
  ChallengeModel _handleStartOver(ChallengeModel challenge) {
    return challenge.copyWith(
      days: [],
      startDate: DateTime.now(),
      numberOfAttempts: challenge.numberOfAttempts + 1,
    );
  }

  /// Extends the challenge duration by one day and marks yesterday as skipped.
  /// Increments grace days spent counter.
  ChallengeModel _handleExtendChallenge(ChallengeModel challenge) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return challenge.copyWith(
      days: [
        ...challenge.days..removeWhere((day) => day.date.withoutTime == yesterday.withoutTime),
        DayModel(
          date: yesterday,
          status: DayStatus.skipped,
        ),
      ],
      targetDays: challenge.targetDays + 1,
      graceDaysSpent: challenge.graceDaysSpent + 1,
    );
  }

  /// Deletes a challenge and removes it from cache.
  /// Returns Success(unit) if successful, Failure otherwise.
  @override
  AsyncResult<Unit> archiveChallenge({
    required String challengeId,
  }) async {
    final challengeResult = await getChallengeById(challengeId);
    if (challengeResult.isError()) {
      return Failure(challengeResult.exceptionOrNull()!);
    }

    final challenge = challengeResult.getOrThrow();
    final updatedChallenge = challenge.copyWith(isArchived: true);
    return _updateAndCache(updatedChallenge, challengeId);
  }

  /// Checks if a given date falls within the challenge period.
  bool _isDateWithinChallengePeriod(DateTime date, ChallengeModel challenge) {
    final endDate = challenge.startDate.add(Duration(days: challenge.targetDays));
    return date.isWithinPeriod(challenge.startDate, endDate);
  }

  /// Updates a challenge and its cache if successful.
  /// Returns Success(unit) if successful, Failure otherwise.
  AsyncResult<Unit> _updateAndCache(
    ChallengeModel challenge,
    String challengeId,
  ) async {
    final result = await _service.updateChallenge(challenge);
    if (result.isSuccess()) {
      updateCache(challengeId, result.getOrThrow());
      return const Success(unit);
    }
    return Failure(result.exceptionOrNull()!);
  }

  DayStatus _toggleDayStatus(DayStatus current) {
    return current == DayStatus.completed ? DayStatus.none : DayStatus.completed;
  }
}

@riverpod
ChallengeRepository challengeRepository(Ref ref) {
  final service = ref.read(challengeServiceLocalProvider);
  final repo = ChallengeRepositoryLocal(service);
  ref.onDispose(repo.dispose);
  return repo;
}
