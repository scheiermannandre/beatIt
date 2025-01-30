import 'dart:async';

import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unchecked_challenges_bottom_sheet_view_model.g.dart';

@riverpod
class UncheckedChallengesBottomSheetViewModel
    extends _$UncheckedChallengesBottomSheetViewModel
    with MessageNotifierMixin {
  late final ChallengeRepository _repository;

  late final Command<List<ChallengeModel>, bool> checkChallengesCommand;
  late final Command<List<ChallengeModel>, bool> closeCommand;
  @override
  FutureOr<void> build() {
    _repository = ref.read(challengeRepositoryProvider);
    checkChallengesCommand = Command.createAsync(
      (uncheckedChallenges) =>
          checkChallenges(uncheckedChallenges: uncheckedChallenges),
      initialValue: true,
    );
    closeCommand = Command.createAsync(
      (uncheckedChallenges) => close(uncheckedChallenges: uncheckedChallenges),
      initialValue: true,
    );
  }

  Future<bool> checkChallenges({
    required List<ChallengeModel> uncheckedChallenges,
  }) async {
    final date = DateTime.now().subtract(const Duration(days: 1));
    state = const AsyncLoading();
    final results = await AsyncValue.guard<
        List<(ChallengeModel, ResultDart<ChallengeModel, Exception>)>>(
      () => Future.wait(
        uncheckedChallenges.map(
          (challenge) => _repository
              .checkChallengeForDate(challengeId: challenge.id, date: date)
              .then((result) => (challenge, result)),
        ),
      ),
    );
    if (results is AsyncError) {
      final error = results.error!;
      state = AsyncError(error, results.stackTrace!);
      showSnackBar(error as AppMessage);
      return false;
    }

    final failures = results.valueOrNull?.where((r) => r.$2.isError()).toList();

    if (failures != null && failures.isNotEmpty) {
      final failedChallenges = failures.map((f) => f.$1.title).join(', ');
      showSnackBar(
        ChallengeException.failedToCheckOneOrMany([failedChallenges]),
      );
      return false;
    }

    state = const AsyncData(null);
    showSnackBar(const ChallengeSuccess.batchChecked());
    return true;
  }

  Future<bool> close({
    required List<ChallengeModel> uncheckedChallenges,
  }) async {
    state = const AsyncLoading();
    final results = await AsyncValue.guard<
        List<(ChallengeModel, ResultDart<Unit, Exception>)>>(
      () => Future.wait(
        uncheckedChallenges.map(
          (challenge) => _repository
              .breakChallengeIfNeeded(challengeId: challenge.id)
              .then((result) => (challenge, result)),
        ),
      ),
    );

    if (results is AsyncError) {
      final error = results.error!;
      state = AsyncError(error, results.stackTrace!);
      showSnackBar(error as AppMessage);
      return false;
    }

    final failures = results.valueOrNull?.where((r) => r.$2.isError()).toList();

    if (failures != null && failures.isNotEmpty) {
      final failedChallenges = failures.map((f) => f.$1.title).join(', ');
      showSnackBar(
        ChallengeException.failedToBreakOneOrMany([failedChallenges]),
      );
    } else {
      showSnackBar(const ChallengeSuccess.batchBroken());
    }

    state = const AsyncData(null);
    return true;
  }
}
