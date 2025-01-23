import 'package:flutter/material.dart';

extension AnimationControllerX on AnimationController {
  Future<void> play() async {
    if (isCompleted) {
      await reverse();
    } else {
      await forward();
    }
  }
}