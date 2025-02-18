import 'package:beat_it/foundation/messaging/app_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum MessageType {
  snackBar,
  dialog,
}

class UIMessage {
  UIMessage({
    required this.message,
    required this.type,
  });
  final AppMessage message;
  final MessageType type;

  void show(BuildContext context) {
    final message = this.message.message(context);
    if (type == MessageType.snackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else if (type == MessageType.dialog) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(title: Text(message)),
      );
    }
  }
}

mixin MessageNotifierMixin {
  final ValueNotifier<UIMessage?> _massageNotifier = ValueNotifier(null);

  void showSnackBar(AppMessage message) {
    _massageNotifier.value = UIMessage(message: message, type: MessageType.snackBar);
  }

  void showDialog(AppMessage message) {
    _massageNotifier.value = UIMessage(message: message, type: MessageType.dialog);
  }
}

void useMessageNotifier(
  BuildContext context,
  MessageNotifierMixin messageNotifier,
) {
  useEffect(
    () {
      final subscription = messageNotifier._massageNotifier.listen((value, _) {
        if (value == null) return;
        value.show(context);
      });
      return subscription.cancel;
    },
    [],
  );
}
