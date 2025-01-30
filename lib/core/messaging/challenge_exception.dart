import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/widgets.dart';

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
  failedToCheckMany,
  failedToBreakOneOrMany,
}

final class ChallengeException extends AppException {
  const ChallengeException._({
    required ChallengeExceptionType type,
    required List<String> messageParameters,
  })  : _type = type,
        _messageParameters = messageParameters;
  const ChallengeException.failedToCreate()
      : this._(
          type: ChallengeExceptionType.failedToCreate,
          messageParameters: const [],
        );
  const ChallengeException.failedToCheck()
      : this._(
          type: ChallengeExceptionType.failedToCheck,
          messageParameters: const [],
        );
  const ChallengeException.failedToArchive()
      : this._(
          type: ChallengeExceptionType.failedToArchive,
          messageParameters: const [],
        );
  const ChallengeException.failedToGet()
      : this._(
          type: ChallengeExceptionType.failedToGet,
          messageParameters: const [],
        );
  const ChallengeException.failedToUpdate()
      : this._(
          type: ChallengeExceptionType.failedToUpdate,
          messageParameters: const [],
        );
  const ChallengeException.failedToDelete()
      : this._(
          type: ChallengeExceptionType.failedToDelete,
          messageParameters: const [],
        );
  const ChallengeException.failedToBreak()
      : this._(
          type: ChallengeExceptionType.failedToBreak,
          messageParameters: const [],
        );
  const ChallengeException.dateOutsideChallengePeriod()
      : this._(
          type: ChallengeExceptionType.dateOutsideChallengePeriod,
          messageParameters: const [],
        );
  const ChallengeException.invalidDuration()
      : this._(
          type: ChallengeExceptionType.invalidDuration,
          messageParameters: const [],
        );
  const ChallengeException.failedToCheckOneOrMany(
    List<String> messageParameters,
  ) : this._(
          type: ChallengeExceptionType.failedToCheckMany,
          messageParameters: messageParameters,
        );
  const ChallengeException.failedToBreakOneOrMany(
    List<String> messageParameters,
  ) : this._(
          type: ChallengeExceptionType.failedToBreakOneOrMany,
          messageParameters: messageParameters,
        );

  final ChallengeExceptionType _type;
  final List<String> _messageParameters;

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
        ChallengeExceptionType.failedToCheckMany =>
          'Failed to check many challenges ${_messageParameters[0]}',
        ChallengeExceptionType.failedToBreakOneOrMany =>
          'Failed to break many challenges ${_messageParameters[0]}',
      };
}
