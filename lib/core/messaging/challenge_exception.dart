import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/widgets.dart';

enum ChallengeExceptionType {
  failedToCreate,
  failedToCheck,
  failedToArchive,
  failedToGet,
  failedToUpdate,
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
        ChallengeExceptionType.failedToCreate =>
          context.l10n.errorFailedToCreate,
        ChallengeExceptionType.failedToCheck => context.l10n.errorFailedToCheck,
        ChallengeExceptionType.failedToArchive =>
          context.l10n.errorFailedToArchive,
        ChallengeExceptionType.failedToGet => context.l10n.errorFailedToGet,
        ChallengeExceptionType.failedToUpdate =>
          context.l10n.errorFailedToUpdate,
        ChallengeExceptionType.failedToBreak => context.l10n.errorFailedToBreak,
        ChallengeExceptionType.dateOutsideChallengePeriod =>
          context.l10n.errorDateOutsideChallengePeriod,
        ChallengeExceptionType.invalidDuration =>
          context.l10n.errorInvalidDuration,
        ChallengeExceptionType.failedToCheckMany =>
          context.l10n.errorFailedToCheckMany(_messageParameters[0]),
        ChallengeExceptionType.failedToBreakOneOrMany =>
          context.l10n.errorFailedToBreakMany(_messageParameters[0]),
      };
}
