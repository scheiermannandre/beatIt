import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/widgets.dart';

enum ChallengeMessageType {
  created,
  checked,
  archived,
  batchChecked,
  empty,
  batchBroken,
}

final class ChallengeSuccess extends AppSuccess {
  const ChallengeSuccess() : _type = ChallengeMessageType.empty;
  const ChallengeSuccess.created() : _type = ChallengeMessageType.created;
  const ChallengeSuccess.checked() : _type = ChallengeMessageType.checked;
  const ChallengeSuccess.archived() : _type = ChallengeMessageType.archived;
  const ChallengeSuccess.batchBroken() : _type = ChallengeMessageType.batchBroken;

  const ChallengeSuccess.batchChecked() : _type = ChallengeMessageType.batchChecked;

  final ChallengeMessageType _type;

  @override
  String message(BuildContext context) => switch (_type) {
        ChallengeMessageType.empty => '',
        ChallengeMessageType.created => context.l10n.successChallengeCreated,
        ChallengeMessageType.checked => context.l10n.successChallengeChecked,
        ChallengeMessageType.archived => context.l10n.successChallengeArchived,
        ChallengeMessageType.batchChecked => context.l10n.successChallengesBatchChecked,
        ChallengeMessageType.batchBroken => context.l10n.successChallengesBatchBroken,
      };
}
