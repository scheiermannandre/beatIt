import 'package:beat_it/core/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';

part 'app_message_provider.g.dart';

enum MessageNotificationType {
  success,
  error,
}

class MessageNotification {
  const MessageNotification({
    required this.message,
    required this.type,
  });

  final String message;
  final MessageNotificationType type;
}

@riverpod
class AppMessageNotifier extends _$AppMessageNotifier {
  @override
  MessageNotification? build(String id) {
    ref.read(appMessageManagerProvider).register(this);
    ref.onDispose(() {
      ref.read(appMessageManagerProvider).unregister(this);
    });
    return null;
  }

  // ignore: use_setters_to_change_properties
  void _show(MessageNotification message) => state = message;
  void clear() => state = null;
}

@Riverpod(keepAlive: true)
AppMessageManager appMessageManager(Ref ref) {
  return AppMessageManager();
}

class AppMessageManager {
  final _notifiers = <String, AppMessageNotifier>{};
  AppMessageNotifier? _lastRegistered;

  void register(AppMessageNotifier notifier) {
    _notifiers[notifier.id] = notifier;
    _lastRegistered = notifier;
  }

  void unregister(AppMessageNotifier notifier) {
    _notifiers.remove(notifier.id);
    if (_lastRegistered?.id == notifier.id) {
      _lastRegistered = _notifiers.values.lastOrNull;
    }
  }

  void showAppMessage(BuildContext context, AppMessage message) {
    switch (message) {
      case AppException():
        showError(message.message(context));
      case AppSuccess():
        showMessage(message.message(context));
    }
  }

  void showMessage(String message) {
    _lastRegistered?._show(
        MessageNotification(message: message, type: MessageNotificationType.success));
  }

  void showError(String message) {
    _lastRegistered?._show(
        MessageNotification(message: message, type: MessageNotificationType.error));
  }
}
