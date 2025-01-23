import 'package:beat_it/core/router/bottom_sheet_route.dart';
import 'package:beat_it/core/router/routes.dart';
import 'package:beat_it/features/challenge/challenge.dart';
import 'package:flutter/widgets.dart';
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
