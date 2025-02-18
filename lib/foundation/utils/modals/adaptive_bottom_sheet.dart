import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/material.dart';

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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                                  style: Theme.of(context).textTheme.titleLarge!,
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
