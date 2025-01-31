import 'package:beat_it/foundation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnimatedProgressIndicator extends HookConsumerWidget {
  const AnimatedProgressIndicator({
    required this.progress,
    required this.challengeId,
    super.key,
  });

  final double progress;
  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      tween: Tween<double>(
        begin: 0,
        end: progress,
      ),
      builder: (context, animatedProgress, child) {
        final percentage = (100 - (animatedProgress * 100)).round();
        final color = Theme.of(context).colorScheme.primary;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipPath(
              clipper: const ShapeBorderClipper(shape: _SharpEdgeShapeBorder()),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .4,
                child: LinearProgressIndicator(
                  value: animatedProgress,
                  minHeight: 10,
                  backgroundColor: color.withCustomOpacity(0.2),
                  color: color,
                ),
              ),
            ),
            Text(
              context.l10n.percentageLeft(percentage),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}

class _SharpEdgeShapeBorder extends ShapeBorder {
  const _SharpEdgeShapeBorder();

  static const double cutWidth = 10;
  static const double radius = 4;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.height / 2)
      ..arcToPoint(
        Offset(rect.left + radius, rect.top),
        radius: const Radius.circular(radius),
      )
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - cutWidth, rect.bottom)
      ..lineTo(rect.left + radius, rect.bottom)
      ..arcToPoint(
        Offset(rect.left, rect.height / 2),
        radius: const Radius.circular(radius),
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
