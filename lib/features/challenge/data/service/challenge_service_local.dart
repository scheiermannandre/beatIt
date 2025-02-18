import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_service_local.g.dart';

class ChallengeServiceLocal {
  ChallengeServiceLocal();

  static const _boxName = 'challenges';

  Box<ChallengeDto>? _box;

  Future<Box<ChallengeDto>> _getBox() async {
    return _box ??= await Hive.openBox<ChallengeDto>(_boxName);
  }

  Future<Result<T>> _handleOperation<T extends Object>({
    required Future<T> Function() operation,
    required ChallengeException error,
  }) async {
    try {
      final result = await operation();
      return Success(result);
    } on Exception {
      return Failure(error);
    }
  }

  AsyncResult<List<ChallengeModel>> getChallenges() => _handleOperation(
        operation: () async {
          final box = await _getBox();
          return box.values.map((dto) => dto.toModel()).toList();
        },
        error: const ChallengeException.failedToGet(),
      );

  AsyncResult<ChallengeModel> getChallengeById(String id) => _handleOperation(
        operation: () async {
          final box = await _getBox();
          final challenge = box.get(id);
          if (challenge == null) throw const ChallengeException.failedToGet();
          return challenge.toModel();
        },
        error: const ChallengeException.failedToGet(),
      );

  AsyncResult<ChallengeModel> createChallenge(ChallengeModel challenge) => _handleOperation(
        operation: () async {
          final box = await _getBox();
          await box.put(challenge.id, ChallengeDto.fromModel(challenge));
          return challenge;
        },
        error: const ChallengeException.failedToCreate(),
      );

  AsyncResult<ChallengeModel> updateChallenge(ChallengeModel challenge) => _handleOperation(
        operation: () async {
          final box = await _getBox();
          await box.put(challenge.id, ChallengeDto.fromModel(challenge));
          return challenge;
        },
        error: const ChallengeException.failedToUpdate(),
      );

  // AsyncResult<void> archiveChallenge(String id) => _handleOperation(
  //       operation: () async {
  //         final box = await _getBox();
  //         final archiveBox = await _getBox(_archiveBoxName);
  //         final dto = box.get(id);

  //         if (dto == null) throw const ChallengeException.failedToGet();

  //         final transaction = HiveTransaction<ChallengeDto>();
  //         await transaction.delete(box, id);
  //         await transaction.put(archiveBox, id, dto);
  //         await transaction.commit();

  //         return unit;
  //       },
  //       error: const ChallengeException.failedToArchive(),
  //     );

  Future<void> onDispose() async {
    await Future.wait(
      [
        _box?.close(),
      ].whereType<Future<dynamic>>(),
    );
    _box = null;
  }
}

@riverpod
ChallengeServiceLocal challengeServiceLocal(Ref ref) {
  final service = ChallengeServiceLocal();
  ref.onDispose(service.onDispose);
  return service;
}
