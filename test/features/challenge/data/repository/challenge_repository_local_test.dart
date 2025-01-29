import 'package:beat_it/features/challenge/challenge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

class MockChallengeServiceLocal extends Mock implements ChallengeServiceLocal {}

void main() {
  late ChallengeRepositoryLocal challengeRepoLocal;
  late MockChallengeServiceLocal mockService;

  setUpAll(() {
    registerFallbackValue(
      ChallengeModelX.empty().copyWith(id: 'fallback'),
    );
  });

  setUp(() {
    mockService = MockChallengeServiceLocal();
    challengeRepoLocal = ChallengeRepositoryLocal(mockService);
  });

  group('breakChallengeIfNeeded', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final baseChallenge = ChallengeModelX.empty().copyWith(
      id: '1',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      targetDays: 10,
    );

    test('does nothing when yesterday was completed', () async {
      // Arrange
      final challenge = baseChallenge.copyWith(
        days: [DayModel(date: yesterday, status: DayStatus.completed)],
      );
      when(() => mockService.getChallenges())
          .thenAnswer((_) async => Success([challenge]));

      await challengeRepoLocal.getChallenges();

      // Act
      final result =
          await challengeRepoLocal.breakChallengeIfNeeded(challengeId: '1');

      // Assert
      expect(result.isSuccess(), true);
      verifyNever(
        () => mockService.updateChallenge(any()),
      );
      verifyNever(() => mockService.archiveChallenge(any()));
    });

    test('does nothing when yesterday was skipped', () async {
      // Arrange
      final challenge = baseChallenge.copyWith(
        days: [DayModel(date: yesterday, status: DayStatus.skipped)],
      );
      when(() => mockService.getChallenges())
          .thenAnswer((_) async => Success([challenge]));
      await challengeRepoLocal.getChallenges();

      // Act
      final result =
          await challengeRepoLocal.breakChallengeIfNeeded(challengeId: '1');

      // Assert
      expect(result.isSuccess(), true);
      verifyNever(
        () => mockService.updateChallenge(any()),
      );
      verifyNever(() => mockService.archiveChallenge(any()));
    });

    test('extends challenge when startOver is disabled', () async {
      // Arrange
      final challenge = baseChallenge.copyWith(
        startOverEnabled: false,
        days: [
          DayModel(
            date: yesterday.subtract(const Duration(days: 1)),
            status: DayStatus.completed,
          ),
        ],
      );
      when(() => mockService.getChallenges())
          .thenAnswer((_) async => Success([challenge]));
      await challengeRepoLocal.getChallenges();

      // Capture the challenge that gets passed to updateChallenge
      ChallengeModel? capturedChallenge;
      when(
        () => mockService.updateChallenge(any()),
      ).thenAnswer((invocation) {
        capturedChallenge =
            invocation.positionalArguments[0] as ChallengeModel;
        return Future.value(Success(challenge));
      });

      // Act
      final result =
          await challengeRepoLocal.breakChallengeIfNeeded(challengeId: '1');

      // Assert
      expect(result.isSuccess(), true);
      verify(
        () => mockService.updateChallenge(any()),
      ).called(1);

      expect(capturedChallenge?.targetDays, challenge.targetDays + 1);
      expect(capturedChallenge?.days.last.status, DayStatus.skipped);
      expect(capturedChallenge?.days.last.date.day, yesterday.day);
    });

    test('resets challenge when startOver is enabled', () async {
      // Arrange
      final challenge = baseChallenge.copyWith(
        startOverEnabled: true,
        graceDaysSpent: 1,
        days: [
          DayModel(
            date: yesterday.subtract(const Duration(days: 1)),
            status: DayStatus.completed,
          ),
        ],
      );
      when(() => mockService.getChallenges())
          .thenAnswer((_) async => Success([challenge]));

      // Capture the challenge that gets passed to updateChallenge
      ChallengeModel? capturedChallenge;
      when(
        () => mockService.updateChallenge(any()),
      ).thenAnswer((invocation) {
        capturedChallenge =
            invocation.positionalArguments[0] as ChallengeModel;
        return Future.value(Success(challenge));
      });

      await challengeRepoLocal.getChallenges();

      // Act
      final result =
          await challengeRepoLocal.breakChallengeIfNeeded(challengeId: '1');

      // Assert
      expect(result.isSuccess(), true);
      verify(
        () => mockService.updateChallenge(any()),
      ).called(1);

      expect(capturedChallenge?.days, isEmpty);
      expect(capturedChallenge?.startDate.day, DateTime.now().day);
    });

    test('deletes challenge when grace days are spent', () async {
      // Arrange
      final challenge = baseChallenge.copyWith(
        graceDaysSpent: ChallengeModel.maxGraceDayCount,
        days: [
          DayModel(
            date: yesterday.subtract(const Duration(days: 1)),
            status: DayStatus.completed,
          ),
        ],
      );
      when(() => mockService.getChallenges())
          .thenAnswer((_) async => Success([challenge]));
      when(() => mockService.archiveChallenge('1'))
          .thenAnswer((_) async => const Success(unit));
      await challengeRepoLocal.getChallenges();
      // Act
      final result =
          await challengeRepoLocal.breakChallengeIfNeeded(challengeId: '1');

      // Assert
      expect(result.isSuccess(), true);
      verify(() => mockService.archiveChallenge('1')).called(1);
      verifyNever(
          () => mockService.updateChallenge(any()),
      );
      final challengeResult = await challengeRepoLocal.getChallengeById('1');
      expect(challengeResult.isError(), true);
    });

    test('returns failure when service fails', () async {
      // Arrange
      when(() => mockService.getChallenges())
          .thenAnswer((_) async => Failure(Exception()));
      await challengeRepoLocal.getChallenges();
      // Act
      final result =
          await challengeRepoLocal.breakChallengeIfNeeded(challengeId: '1');

      // Assert
      expect(result.isError(), true);
      verifyNever(
        () => mockService.updateChallenge(any()),
      );
      verifyNever(() => mockService.archiveChallenge(any()));
    });
  });
}
