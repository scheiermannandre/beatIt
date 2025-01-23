import 'package:flutter/widgets.dart';

enum ChallengeMessageType {
  created,
  checked,
  archived,
}

enum ChallengeExceptionType {
  failedToCreate,
  failedToCheck,
  failedToArchive,
  failedToGet,
  failedToUpdate,
  failedToDelete,
  failedToBreak,
  dateOutsideChallengePeriod,
  invalidDuration,
}

sealed class AppMessage {
  const AppMessage();
  String message(BuildContext context);
}

sealed class AppSuccess implements AppMessage {
  const AppSuccess();
}

sealed class AppException implements AppMessage, Exception {
  const AppException();
}

final class ChallengeSuccess extends AppSuccess {
  const ChallengeSuccess.created() : _type = ChallengeMessageType.created;
  const ChallengeSuccess.checked() : _type = ChallengeMessageType.checked;
  const ChallengeSuccess.archived() : _type = ChallengeMessageType.archived;

  final ChallengeMessageType _type;

  @override
  String message(BuildContext context) => switch (_type) {
        ChallengeMessageType.created => 'Challenge created successfully',
        ChallengeMessageType.checked => 'Challenge checked successfully',
        ChallengeMessageType.archived => 'Challenge archived successfully',
      };
}

final class ChallengeException extends AppException {
  const ChallengeException.failedToCreate()
      : _type = ChallengeExceptionType.failedToCreate;
  const ChallengeException.failedToCheck()
      : _type = ChallengeExceptionType.failedToCheck;
  const ChallengeException.failedToArchive()
      : _type = ChallengeExceptionType.failedToArchive;
  const ChallengeException.failedToGet()
      : _type = ChallengeExceptionType.failedToGet;
  const ChallengeException.failedToUpdate()
      : _type = ChallengeExceptionType.failedToUpdate;
  const ChallengeException.failedToDelete()
      : _type = ChallengeExceptionType.failedToDelete;
  const ChallengeException.failedToBreak()
      : _type = ChallengeExceptionType.failedToBreak;
  const ChallengeException.dateOutsideChallengePeriod()
      : _type = ChallengeExceptionType.dateOutsideChallengePeriod;
  const ChallengeException.invalidDuration()
      : _type = ChallengeExceptionType.invalidDuration;

  final ChallengeExceptionType _type;

  @override
  String message(BuildContext context) => switch (_type) {
        ChallengeExceptionType.failedToCreate => 'Failed to create challenge',
        ChallengeExceptionType.failedToCheck => 'Failed to check challenge',
        ChallengeExceptionType.failedToArchive => 'Failed to archive challenge',
        ChallengeExceptionType.failedToGet => 'Failed to get challenge',
        ChallengeExceptionType.failedToUpdate => 'Failed to update challenge',
        ChallengeExceptionType.failedToDelete => 'Failed to delete challenge',
        ChallengeExceptionType.failedToBreak => 'Failed to break challenge',
        ChallengeExceptionType.dateOutsideChallengePeriod =>
          'Date is outside challenge period',
        ChallengeExceptionType.invalidDuration =>
          'Challenge duration must be greater than 0',
      };
}
