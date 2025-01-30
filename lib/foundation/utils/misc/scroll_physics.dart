import 'package:flutter/material.dart';

class UnboundedNotDismissingBouncingScrollPhysics extends ScrollPhysics {
  const UnboundedNotDismissingBouncingScrollPhysics({super.parent});

  @override
  UnboundedNotDismissingBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return UnboundedNotDismissingBouncingScrollPhysics(
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Only apply boundary conditions at the bottom
    if (value > position.maxScrollExtent) {
      return value - position.maxScrollExtent;
    }
    return 0;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) =>
      offset;

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;
  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    return BouncingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      leadingExtent: 0,
      trailingExtent: position.maxScrollExtent,
      spring: SpringDescription.withDampingRatio(
        mass: 0.5,
        stiffness: 500,
        ratio: 1.1,
      ),
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}

class UnboundedBouncingScrollPhysics extends ScrollPhysics {
  const UnboundedBouncingScrollPhysics({
    required this.onTopThresholdOverscrolled,
    super.parent,
  });

  final VoidCallback onTopThresholdOverscrolled;

  @override
  UnboundedBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return UnboundedBouncingScrollPhysics(
      parent: buildParent(ancestor),
      onTopThresholdOverscrolled: onTopThresholdOverscrolled,
    );
  }

  double _getDismissThreshold(ScrollMetrics position) {
    return -(position.viewportDimension * 0.3);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Only apply boundary conditions at the bottom
    if (value > position.maxScrollExtent) {
      return value - position.maxScrollExtent;
    }
    return 0;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) =>
      offset;

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Check for dismiss threshold only if snapBackAfterThreshold is false
    if (position.pixels <= _getDismissThreshold(position)) {
      onTopThresholdOverscrolled();
      // Return a simulation that continues the motion downward
      return null;
    }

    return BouncingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      leadingExtent: 0,
      trailingExtent: position.maxScrollExtent,
      spring: SpringDescription.withDampingRatio(
        mass: 0.5,
        stiffness: 500,
        ratio: 1.1,
      ),
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
