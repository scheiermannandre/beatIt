import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SizeEffect extends Effect<double> {
  const SizeEffect({
    super.delay,
    super.duration,
    super.curve,
    this.axis = Axis.vertical,
  });

  final Axis axis;

  @override
  Widget build(
    BuildContext context,
    Widget child,
    AnimationController controller,
    EffectEntry entry,
  ) {
    return SizeTransition(
      sizeFactor: controller,
      axis: axis,
      child: child,
    );
  }
}