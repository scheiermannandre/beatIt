import 'dart:async';

import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:result_dart/result_dart.dart';

/// Repository for managing challenges with caching and real-time updates.
///
/// Provides methods for:
/// - CRUD operations on challenges
/// - Real-time challenge updates via streams
/// - Local caching with batch operations
abstract class ChallengeRepository {
  /// Emits a stream of all challenges, updated in real-time.
  ///
  /// The stream emits a new value whenever:
  /// - A challenge is created, updated, or deleted
  /// - The cache is updated via [updateCache] or [updateCacheInBatch]
  Stream<List<ChallengeModel>> observeChallenges() => _challengesController.stream;

  final _challengesController = StreamController<List<ChallengeModel>>.broadcast();

  final Map<String, ChallengeModel> _cache = {};

  Stream<ChallengeModel> observeChallengeById(String id) => observeChallenges().map((challenges) {
        return challenges.firstWhere(
          (c) => c.id == id,
          orElse: () => throw const ChallengeException.failedToGet(),
        );
      });

  Stream<List<ChallengeModel>> observeCurrentChallenges() => observeChallenges().map((challenges) {
        return challenges
            .where(
              (c) => c.startDate.withoutTime.isBeforeOrAt(DateTime.now().withoutTime) && !(c.isArchived ?? false),
            )
            .toList();
      });

  Stream<List<ChallengeModel>> observeArchivedChallenges() => observeChallenges().map((challenges) {
        return challenges.where((c) => c.isArchived ?? false).toList();
      });

  Stream<List<ChallengeModel>> observeFutureChallenges() => observeChallenges().map((challenges) {
        return challenges
            .where(
              (c) => c.startDate.withoutTime.isAfter(DateTime.now().withoutTime) && !(c.isArchived ?? false),
            )
            .toList();
      });

  AsyncResult<ChallengeModel> getChallengeById(String id) async {
    if (!_cache.containsKey(id)) {
      return const Failure(ChallengeException.failedToGet());
    }
    return Success(_cache[id]!);
  }

  AsyncResult<List<ChallengeModel>> getChallenges();
  AsyncResult<Unit> createChallenge({
    required ChallengeModel challenge,
  });

  AsyncResult<List<ChallengeModel>> getFutureChallenges();
  AsyncResult<List<ChallengeModel>> getCurrentChallenges();
  AsyncResult<List<ChallengeModel>> getArchivedChallenges();

  AsyncResult<ChallengeModel> checkChallengeForDate({
    required String challengeId,
    required DateTime date,
  });

  AsyncResult<List<ChallengeModel>> analyzeChallenges();

  AsyncResult<Unit> enableStartOver({
    required String challengeId,
    required bool enable,
  });

  AsyncResult<Unit> archiveChallenge({
    required String challengeId,
  });

  AsyncResult<Unit> breakChallengeIfNeeded({
    required String challengeId,
  });

  void updateCache(String id, ChallengeModel challenge) {
    _cache[id] = challenge;
    _emitCachedChallenges();
  }

  void updateCacheInBatch(List<ChallengeModel> challenges) {
    for (final challenge in challenges) {
      _cache[challenge.id] = challenge;
    }
    _emitCachedChallenges();
  }

  void deleteFromCache(String id) {
    _cache.remove(id);
    _emitCachedChallenges();
  }

  void _emitCachedChallenges() {
    if (_challengesController.isClosed) return;
    _challengesController.add(_cache.values.toList());
  }

  void dispose() {
    _challengesController.close();
  }
}
