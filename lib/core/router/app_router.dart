import 'package:beat_it/core/core.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoute.dashboard.path,
      name: AppRoute.dashboard.name,
      builder: (context, state) => const DashboardScreen(),
      routes: [
        GoRoute(
          path: AppRoute.createChallenge.path,
          name: AppRoute.createChallenge.name,
          builder: (context, state) => const CreateChallengeScreen(),
        ),
        GoRoute(
          path: AppRoute.challenge.path,
          name: AppRoute.challenge.name,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChallengeDetailsScreen(challengeId: id);
          },
        ),
      ],
    ),
  ],
);
