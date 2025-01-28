import 'package:beat_it/utils/utils.dart';
import 'package:flutter/material.dart';

enum ChallengeDurationLabel {
  days,
  weeks,
  months,
  years;
}

enum ChallengeDuration {
  sevenDays(7, ChallengeDurationLabel.days, 7),
  tenDays(10, ChallengeDurationLabel.days, 10),
  fourteenDays(14, ChallengeDurationLabel.days, 14),
  twentyOneDays(21, ChallengeDurationLabel.days, 21),
  thirtyDays(30, ChallengeDurationLabel.days, 30),
  threeMonths(3, ChallengeDurationLabel.months, 90),
  sixMonths(6, ChallengeDurationLabel.months, 180),
  oneYear(1, ChallengeDurationLabel.years, 365);

  const ChallengeDuration(this.uiAmount, this.label, this.amount);
  final int uiAmount;
  final int amount;
  final ChallengeDurationLabel label;

  String getLabel(BuildContext context) {
    return '$uiAmount ${label.name.hardcoded}';
  }
}
