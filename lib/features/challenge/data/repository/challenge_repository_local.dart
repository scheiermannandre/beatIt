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

  @override
  AsyncResult<List<ChallengeModel>> checkNeedToArchiveChallenge() async {
    final result = await getChallenges();
    if (result.isError()) return result;

    final challenges = result.getOrThrow();
    final now = DateTime.now();

    final challengesToArchive = challenges.where((challenge) {
      // Skip if already archived
      if (challenge.isArchived ?? false) return false;

      // Check if challenge end date is in the past for 2+ days
      // yesterday is not included, because it first needs to go through
      // the users evaluation if done or not done via bottom sheet
      final endDate = challenge.startDate.add(Duration(days: challenge.targetDays - 2));
      return endDate.withoutTime.isBefore(now.withoutTime);
    }).toList();

    if (challengesToArchive.isEmpty) {
      return Success(challengesToArchive);
    }

    // Archive all past challenges
    final results = await Future.wait(
      challengesToArchive.map(
        (challenge) => archiveChallenge(challengeId: challenge.id),
      ),
    );

    // Check if any archive operations failed
    final failures = results.where((r) => r.isError()).toList();
    if (failures.isNotEmpty) {
      return const Failure(ChallengeException.failedToArchive());
    }

    return getChallenges();
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

    var updatedChallenge = _updateChallengeDay(currentChallenge, date);
    final updateResult = await _service.updateChallenge(updatedChallenge);
    if (updateResult.isSuccess()) {
      updateCache(challengeId, updateResult.getOrThrow());
    }

    updatedChallenge = updateResult.getOrThrow();
    // Check if challenge is completed (completed days = target days - grace days spent)
    final completedDays = updatedChallenge.days.where((day) => day.status == DayStatus.completed).length;
    if (completedDays == updatedChallenge.targetDays - updatedChallenge.graceDaysSpent) {
      final archiveResult = await archiveChallenge(challengeId: challengeId);
      if (archiveResult.isError()) {
        return Failure(archiveResult.exceptionOrNull()!);
      }
    }
    await getChallenges();
    return Success(updatedChallenge);
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

  /// Checks if a challenge needs to be broken due to missed days.
  /// Returns Success(unit) if successful, Failure otherwise.
  @override
  AsyncResult<Unit> breakChallengeIfNeeded({
    required String challengeId,
    DateTime? date,
  }) async {
    final challengeResult = await getChallengeById(challengeId);
    if (challengeResult.isError()) {
      return Failure(challengeResult.exceptionOrNull()!);
    }

    final challenge = challengeResult.getOrThrow();
    final dateToCheck = date ?? DateTime.now().subtract(const Duration(days: 1));

    // Skip if date is outside challenge period
    if (!_isDateWithinChallengePeriod(dateToCheck, challenge)) {
      return const Success(unit);
    }

    // Skip if day is already marked
    if (challenge.days.any(
      (day) => day.date.withoutTime == dateToCheck.withoutTime,
    )) {
      return const Success(unit);
    }

    // If start over is enabled, reset the challenge
    if (challenge.startOverEnabled) {
      final updatedChallenge = challenge.copyWith(
        startDate: DateTime.now(),
        days: [], // Clear all previous days
        graceDaysSpent: 0, // Reset grace days
        numberOfAttempts: challenge.numberOfAttempts + 1,
      );
      return _updateAndCache(updatedChallenge, challengeId);
    }

    // Otherwise use grace days system
    final updatedChallenge = challenge.copyWith(
      days: [
        ...challenge.days,
        DayModel(
          date: dateToCheck,
          status: DayStatus.skipped,
        ),
      ],
      graceDaysSpent: challenge.graceDaysSpent + 1,
      targetDays: challenge.targetDays + 1, // Add one day for each grace day used
    );

    // Only archive if grace days are spent AND start over is not enabled
    if (updatedChallenge.areGraceDaysSpent && !challenge.startOverEnabled) {
      return archiveChallenge(challengeId: challengeId);
    }

    return _updateAndCache(updatedChallenge, challengeId);
  }

  /// Checks all active challenges for missed days up to yesterday and breaks them if needed
  @override
  AsyncResult<List<ChallengeModel>> checkNeedToBreakChallenges() async {
    final result = await getChallenges();
    if (result.isError()) return result;

    final challenges = result.getOrThrow();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    final activeChallenges = challenges.where((challenge) {
      // Skip archived challenges
      if (challenge.isArchived ?? false) return false;

      // Only check challenges that have started and haven't ended
      final endDate = challenge.startDate.add(Duration(days: challenge.targetDays));
      return challenge.startDate.withoutTime.isBeforeOrAt(yesterday.withoutTime) &&
          endDate.withoutTime.isAfterOrAt(yesterday.withoutTime);
    }).toList();

    if (activeChallenges.isEmpty) {
      return Success(activeChallenges);
    }

    // Check each challenge for missed days
    for (final challenge in activeChallenges) {
      var currentDate = challenge.startDate;

      while (currentDate.withoutTime.isBefore(yesterday.withoutTime)) {
        // Skip if day is already marked
        if (!challenge.days.any(
          (day) => day.date.withoutTime == currentDate.withoutTime,
        )) {
          // Day was missed, mark it and check if challenge should be broken
          final result = await breakChallengeIfNeeded(
            challengeId: challenge.id,
            date: currentDate, // Pass the specific date to check
          );
          if (result.isError()) {
            return Failure(result.exceptionOrNull()!);
          }
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return getChallenges();
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
