import 'package:beat_it/utils/utils.dart';
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
              'No challenges yet'.hardcoded,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first challenge to get started'.hardcoded,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateChallenge,
              icon: const Icon(Icons.add),
              label: Text('Create Challenge'.hardcoded),
            ),
          ],
        ),
      ),
    );
  }
}
