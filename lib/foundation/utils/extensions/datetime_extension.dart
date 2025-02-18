extension DateTimeExtension on DateTime {
  DateTime get withoutTime => DateTime(year, month, day);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isWithinPeriod(DateTime start, DateTime end) {
    return !isBefore(start) && !isAfter(end);
  }

  bool isBeforeOrAt(DateTime other) {
    return isBefore(other) || isSameDay(other);
  }
}
