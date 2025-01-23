import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unchecked_challenges_analyzer_provider.g.dart';

@Riverpod(keepAlive: true)
class UncheckedChallengesAnalyzer extends _$UncheckedChallengesAnalyzer {
  @override
  bool build() => false;
  DateTime? lastCheck;

  void shouldCheckChallenges() {
    final now = DateTime.now();

    if (this.lastCheck == null) {
      state = true;
      this.lastCheck = now;
      return;
    }

    final lastCheck = this.lastCheck!;
    state = now.year != lastCheck.year ||
        now.month != lastCheck.month ||
        now.day != lastCheck.day;
  }
}
