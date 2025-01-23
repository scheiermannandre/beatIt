import 'package:beat_it/core/providers/app_message_provider.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:result_dart/result_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_challenge_view_model.g.dart';

typedef CreateChallengeParams = ({
  String name,
  int duration,
  bool startOverEnabled,
  DateTime startDate,
});

@riverpod
class CreateChallengeViewModel extends _$CreateChallengeViewModel {
  late final AppMessageManager _appMessageManager;
  late final Command<CreateChallengeParams, Result<Unit>>
      createChallengeCommand;
  late final ChallengeRepository _challengeRepository;
  @override
  FutureOr<void> build() {
    // Initial state
    _appMessageManager = ref.read(appMessageManagerProvider);
    _challengeRepository = ref.read(challengeRepositoryProvider);
    createChallengeCommand =
        Command.createAsync<CreateChallengeParams, Result<Unit>>(
      (params) => _createChallenge(
        name: params.name,
        duration: params.duration,
        startOverEnabled: params.startOverEnabled,
        startDate: params.startDate,
      ),
      initialValue: const Success(unit),
    );
    return null;
  }

  Future<Result<Unit>> _createChallenge({
    required String name,
    required int duration,
    required bool startOverEnabled,
    required DateTime startDate,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    final challenge = ChallengeModel.withId(
      title: name,
      targetDays: duration,
      startDate: startDate,
      days: const [],
      startOverEnabled: startOverEnabled,
      createdAt: now,
    );

    final result =
        await _challengeRepository.createChallenge(challenge: challenge);
    return result.fold(
      (success) {
        state = const AsyncData(null);
        return const Success(unit);
      },
      (failure) {
        state = AsyncError(
          'Failed to create challenge',
          StackTrace.current,
        );
        _appMessageManager.showError('Failed to create challenge');
        return Failure(Exception('Failed to create challenge'));
      },
    );
  }
}
