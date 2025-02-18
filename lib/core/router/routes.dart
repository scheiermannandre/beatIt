import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  static const dashboard = (
    name: 'dashboard',
    path: '/',
  );

  static const createChallenge = (
    name: 'create_challenge',
    path: 'create',
  );

  static const challenge = (
    name: 'challenge',
    path: 'challenge/:id',
  );

  static String challengePath(String id) => 'challenge/$id';
}

extension GoRouterContextX on BuildContext {
  void pushChallenge({required String id, required bool isArchived}) => pushNamed(
        AppRoute.challenge.name,
        pathParameters: {'id': id},
        queryParameters: {'isArchived': isArchived.toString()},
      );

  void pushCreateChallenge() => pushNamed(AppRoute.createChallenge.name);
}
