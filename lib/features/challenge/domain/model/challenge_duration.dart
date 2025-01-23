import 'package:beat_it/utils/utils.dart';
import 'package:flutter/material.dart';

enum ChallengeDurationLabel {
  days,
  weeks,
  months,
  years;
}

enum ChallengeDuration {
  sevenDays(7, ChallengeDurationLabel.days),
  tenDays(10, ChallengeDurationLabel.days),
  fourteenDays(14, ChallengeDurationLabel.days),
  twentyOneDays(21, ChallengeDurationLabel.days),
  thirtyDays(30, ChallengeDurationLabel.days),
  threeMonths(3, ChallengeDurationLabel.months),
  sixMonths(6, ChallengeDurationLabel.months),
  oneYear(1, ChallengeDurationLabel.years);

  const ChallengeDuration(this.amount, this.label);
  final int amount;
  final ChallengeDurationLabel label;

  String getLabel(BuildContext context) {
    return '$amount ${label.name.hardcoded}';
  }
}
