import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SheetRoute<T> extends CustomTransitionPage<T> {
  SheetRoute({
    required super.child,
    super.key,
    this.title,
    this.isDismissible = true,
    this.enableDrag = true,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(color: Colors.black54),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutCubic)),
                    ),
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      child: SafeArea(
                        top: false,
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
                                  if (isDismissible)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => context.pop(),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (title != null) ...[
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
                            ],
                            Flexible(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: child,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          barrierDismissible: isDismissible,
          barrierColor: Colors.black54,
          opaque: false,
          maintainState: false,
        );

  final Widget? title;
  final bool isDismissible;
  final bool enableDrag;
}

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

Page<T> buildSheetPage<T>({
  required BuildContext context,
  required Widget child,
  Widget? title,
  bool? isDismissible,
  bool? enableDrag,
}) {
  return SheetRoute<T>(
    child: child,
    title: title,
    isDismissible: isDismissible ?? true,
    enableDrag: enableDrag ?? true,
  );
}
