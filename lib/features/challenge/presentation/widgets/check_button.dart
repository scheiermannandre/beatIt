import 'package:beat_it/features/challenge/challenge.dart';
import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CheckButton extends HookConsumerWidget {
  const CheckButton({
    required this.challengeId,
    required this.date,
    this.isLoading,
    super.key,
  });

  final String challengeId;
  final DateTime date;
  final ValueNotifier<bool>? isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeModelAsyncValue = ref.watch(challengeViewModelProvider(challengeId));
    final challengeViewModel = ref.watch(challengeViewModelProvider(challengeId).notifier);
    useMessageNotifier(context, challengeViewModel);
    final challengeModel = challengeModelAsyncValue.valueOrNull;
    final theme = Theme.of(context);
    final isDayCompleted = challengeModel?.isDayCompleted(date: date) ?? false;
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
    );
    final isLoadingInternal = useState(false);
    useEffect(
      () {
        var mounted = true;
        final subscription = challengeViewModel.checkChallengeCommand.results.listen((result, _) async {
          if (!mounted) return;

          // Only update if still mounted
          isLoading?.value = result.isExecuting;
          isLoadingInternal.value = result.isExecuting;
          if (result.data?.isError() ?? false || result.isExecuting) return;
          await animationController.play();
        });

        return () {
          mounted = false;
          subscription.cancel();
        };
      },
      [isDayCompleted],
    );
    return Animate(
      autoPlay: false,
      controller: animationController,
      effects: [
        ScaleEffect(
          curve: Curves.easeInOut,
          duration: 200.ms,
          begin: isDayCompleted ? const Offset(1, 1) : const Offset(1.2, 1.2),
          end: isDayCompleted ? const Offset(1.2, 1.2) : const Offset(1, 1),
        ),
        const ThenEffect(),
        ScaleEffect(
          curve: Curves.easeInOut,
          duration: 100.ms,
          begin: isDayCompleted ? const Offset(1, 1) : const Offset(.85, .85),
          end: isDayCompleted ? const Offset(.85, .85) : const Offset(1, 1),
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDayCompleted ? theme.colorScheme.primary : theme.colorScheme.primary.withCustomOpacity(.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Button.icon(
          onPressed: (isLoading?.value ?? false)
              ? null
              // ignore: void_checks
              : () => challengeViewModel.checkChallengeCommand.execute(date),
          icon: const Icon(Icons.check, color: Colors.white),
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Use rectangular splash instead of circular
            splashFactory: InkRipple.splashFactory,
          ),
          isLoading: isLoadingInternal.value,
        ),
      ),
    );
  }
}
