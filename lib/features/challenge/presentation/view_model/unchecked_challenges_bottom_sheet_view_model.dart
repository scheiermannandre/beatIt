import 'package:beat_it/core/providers/app_message_provider.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unchecked_challenges_bottom_sheet_view_model.g.dart';

@riverpod
class UncheckedChallengesBottomSheetViewModel
    extends _$UncheckedChallengesBottomSheetViewModel {
  late final ChallengeRepository _repository;
  late final AppMessageManager _appMessageManager;

  late final Command<List<ChallengeModel>, Result<Unit>> checkChallengesCommand;
  late final Command<List<ChallengeModel>, Result<Unit>> closeCommand;
  @override
  FutureOr<void> build() {
    _repository = ref.read(challengeRepositoryProvider);
    _appMessageManager = ref.read(appMessageManagerProvider);
    checkChallengesCommand = Command.createAsync(
      (uncheckedChallenges) =>
          checkChallenges(uncheckedChallenges: uncheckedChallenges),
      initialValue: const Success(unit),
    );
    closeCommand = Command.createAsync(
      (uncheckedChallenges) => close(uncheckedChallenges: uncheckedChallenges),
      initialValue: const Success(unit),
    );
  }

  AsyncResult<Unit> checkChallenges({
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
      state = AsyncError(results.error!, results.stackTrace!);
      _appMessageManager.showError(
        'An error occurred while checking challenges',
      );
      return Failure(results.error! as Exception);
    }

    final failures = results.valueOrNull?.where((r) => r.$2.isError()).toList();

    if (failures != null && failures.isNotEmpty) {
      final failedChallenges = failures.map((f) => f.$1.title).join(', ');
      _appMessageManager.showError(
        'Failed to check challenges: $failedChallenges',
      );
    } else {
      _appMessageManager.showMessage('All challenges checked successfully');
    }

    state = const AsyncData(null);
    return const Success(unit);
  }

  AsyncResult<Unit> close({
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
      state = AsyncError(results.error!, results.stackTrace!);
      _appMessageManager.showError(
        'An error occurred while breaking challenges',
      );
      return Failure(results.error! as Exception);
    }

    final failures = results.valueOrNull?.where((r) => r.$2.isError()).toList();

    if (failures != null && failures.isNotEmpty) {
      final failedChallenges = failures.map((f) => f.$1.title).join(', ');
      _appMessageManager.showError(
        'Failed to break challenges: $failedChallenges',
      );
    } else {
      _appMessageManager.showMessage('All challenges broken successfully');
    }

    state = const AsyncData(null);
    return const Success(unit);
  }
}
