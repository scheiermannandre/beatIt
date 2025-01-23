import 'package:beat_it/features/challenge/challenge.dart';
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

Future<T?> showAdaptiveBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  Widget? title,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  var isDismissed = false;
  final maxHeight = MediaQuery.of(context).size.height;

  ScrollPhysics physics = const NeverScrollableScrollPhysics();
  if (enableDrag && isDismissible) {
    physics = UnboundedBouncingScrollPhysics(
      onTopThresholdOverscrolled: () {
        if (!isDismissed) {
          isDismissed = true;
          Navigator.pop(context);
        }
      },
    );
  } else if (enableDrag && !isDismissible) {
    physics = const UnboundedNotDismissingBouncingScrollPhysics();
  } else {
    physics = const NeverScrollableScrollPhysics();
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: isDismissible ? () => Navigator.pop(context) : null,
        behavior: HitTestBehavior.opaque,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent taps from propagating through the sheet
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              constraints: BoxConstraints(
                maxHeight: maxHeight * 0.9,
              ),
              child: Builder(
                builder: (context) => SingleChildScrollView(
                  physics: physics,
                  child: Material(
                    color: Theme.of(context).bottomSheetTheme.backgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 48,
                              child: Stack(
                                children: [
                                  const Align(
                                    child: _BottomSheetHandle(),
                                  ),
                                  Visibility(
                                    visible: isDismissible,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (title != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 8,
                                ),
                                child: DefaultTextStyle(
                                  style:
                                      Theme.of(context).textTheme.titleLarge!,
                                  textAlign: TextAlign.center,
                                  child: title,
                                ),
                              ),
                            Flexible(
                              child: child,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

Future<SelectionValue<T, V>?> showSelectionBottomSheet<T extends Enum, V>({
  required BuildContext context,
  required String title,
  required List<T> values,
  required String Function(T) labelExtractor,
  Widget? customWidget,
}) {
  return showAdaptiveBottomSheet<SelectionValue<T, V>>(
    context: context,
    title: Text(title),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...values.map(
          (value) => ListTile(
            title: Text(labelExtractor(value)),
            onTap: () => Navigator.pop(
              context,
              EnumValue<T, V>(
                value: value,
                labelExtractor: labelExtractor,
              ),
            ),
          ),
        ),
        if (customWidget != null) ...[
          const Divider(),
          customWidget,
        ],
      ],
    ),
  );
}
