import 'package:flutter/material.dart';

sealed class AppMessage {
  const AppMessage();
  String message(BuildContext context);
}

abstract class AppSuccess implements AppMessage {
  const AppSuccess();
}

abstract class AppException implements AppMessage, Exception {
  const AppException();
}
