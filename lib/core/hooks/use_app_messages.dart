import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:beat_it/core/providers/app_message_provider.dart';

// void useAppMessages(BuildContext context, WidgetRef ref) {
//   ref.listen<AppMessage?>(
//     appMessageNotifierProvider,
//     (previous, next) {
//       if (next == null) return;

//       ScaffoldMessenger.of(context)
//         ..clearSnackBars()
//         ..showSnackBar(
//           SnackBar(
//             content: Text(next.message),
//             backgroundColor: next.type == AppMessageType.error
//                 ? Theme.of(context).colorScheme.error
//                 : Theme.of(context).colorScheme.primary,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );

//       ref.read(appMessageNotifierProvider.notifier).clear();
//     },
//   );
// }

void useAppMessages(BuildContext context, WidgetRef ref, String id) {
  ref.listen(appMessageNotifierProvider(id), (previous, next) {
    if (next == null) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(next.message)));

    ref.read(appMessageNotifierProvider(id).notifier).clear();
  });
}
