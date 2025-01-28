import 'package:beat_it/features/challenge/challenge.dart';
import 'package:flutter/material.dart';

sealed class DurationSelection {
  const DurationSelection();

  int get days;
  String getLabel(BuildContext context);
}

class EnumDuration extends DurationSelection {
  const EnumDuration(this.value);

  final ChallengeDuration value;

  @override
  int get days => value.uiAmount;

  @override
  String getLabel(BuildContext context) => value.getLabel(context);
}

class CustomDuration extends DurationSelection {
  const CustomDuration({
    required this.days,
    required this.label,
  });

  @override
  final int days;

  final String label;

  @override
  String getLabel(BuildContext context) => label;
}
