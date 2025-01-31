import 'package:beat_it/foundation/utils/utils.dart';
import 'package:flutter/material.dart';

class NoChallenges extends StatelessWidget {
  const NoChallenges({
    required this.onCreateChallenge,
    super.key,
  });

  final VoidCallback onCreateChallenge;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.uiNoChallenges,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.uiCreateFirstChallenge,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateChallenge,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.uiCreateChallenge),
            ),
          ],
        ),
      ),
    );
  }
}
