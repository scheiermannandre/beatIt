import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:beat_it/features/challenge/presentation/providers/unchecked_challenges_analyzer_provider.dart';

part 'app_lifecycle_provider.g.dart';

@Riverpod(keepAlive: true)
class AppLifecycle extends _$AppLifecycle with WidgetsBindingObserver {
  @override
  AppLifecycleState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return AppLifecycleState.resumed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
    if (state == AppLifecycleState.resumed) {
      ref.read(uncheckedChallengesAnalyzerProvider.notifier).shouldCheckChallenges();
    }
  }
}
