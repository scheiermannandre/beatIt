import 'dart:convert';

import 'package:beat_it/foundation/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

@immutable
class ChallengeModel {
  const ChallengeModel({
    required List<DayModel> days,
    required this.id,
    required this.title,
    required this.targetDays,
    required this.startDate,
    required this.graceDaysSpent,
    required this.createdAt,
    required this.numberOfAttempts,
    this.lastCompletedDate,
    this.isArchived = false,
    this.startOverEnabled = false,
  }) : _days = days;

  ChallengeModel.withId({
    required this.title,
    required this.targetDays,
    required this.startDate,
    required List<DayModel> days,
    required this.createdAt,
    this.graceDaysSpent = 0,
    this.lastCompletedDate,
    this.isArchived = false,
    this.startOverEnabled = false,
    this.numberOfAttempts = 1,
  })  : _days = days,
        id = const Uuid().v4();

  factory ChallengeModel.fromMap(Map<String, dynamic> map) {
    return ChallengeModel(
      id: map['id'] as String,
      title: map['title'] as String,
      targetDays: map['targetDays'] as int,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      days: List<DayModel>.from(
        (map['_days'] as List<int>).map<DayModel>(
          (x) => DayModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      lastCompletedDate: map['lastCompletedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastCompletedDate'] as int)
          : null,
      isArchived: map['isArchived'] != null ? map['isArchived'] as bool : null,
      startOverEnabled: map['startOverEnabled'] as bool,
      graceDaysSpent: map['graceDaysSpent'] as int,
      numberOfAttempts: map['numberOfAttempts'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  factory ChallengeModel.fromJson(String source) => ChallengeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static const maxGraceDayCount = 3;
  final String id;
  final String title;
  final int targetDays;
  final DateTime startDate;
  final List<DayModel> _days;
  List<DayModel> get days => List<DayModel>.from(_days)..sort((a, b) => a.date.compareTo(b.date));

  final DateTime? lastCompletedDate;
  final bool? isArchived;
  final bool startOverEnabled;
  final int graceDaysSpent;
  final int numberOfAttempts;
  final DateTime createdAt;

  ChallengeModel copyWith({
    String? id,
    String? title,
    int? targetDays,
    DateTime? startDate,
    List<DayModel>? days,
    DateTime? lastCompletedDate,
    bool? isArchived,
    bool? startOverEnabled,
    int? graceDaysSpent,
    DateTime? createdAt,
    int? numberOfAttempts,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDays: targetDays ?? this.targetDays,
      startDate: startDate ?? this.startDate,
      days: days ?? this.days,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      isArchived: isArchived ?? this.isArchived,
      startOverEnabled: startOverEnabled ?? this.startOverEnabled,
      graceDaysSpent: graceDaysSpent ?? this.graceDaysSpent,
      createdAt: createdAt ?? this.createdAt,
      numberOfAttempts: numberOfAttempts ?? this.numberOfAttempts,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'targetDays': targetDays,
      'startDate': startDate.millisecondsSinceEpoch,
      '_days': _days.map((x) => x.toMap()).toList(),
      'lastCompletedDate': lastCompletedDate?.millisecondsSinceEpoch,
      'isArchived': isArchived,
      'startOverEnabled': startOverEnabled,
      'graceDaysSpent': graceDaysSpent,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return '''ChallengeModel(id: $id, title: $title, targetDays: $targetDays, startDate: $startDate, _days: $_days, lastCompletedDate: $lastCompletedDate, isArchived: $isArchived, startOverEnabled: $startOverEnabled, graceDaysSpent: $graceDaysSpent, createdAt: $createdAt)''';
  }

  @override
  bool operator ==(covariant ChallengeModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.targetDays == targetDays &&
        other.startDate == startDate &&
        listEquals(other._days, _days) &&
        other.lastCompletedDate == lastCompletedDate &&
        other.isArchived == isArchived &&
        other.startOverEnabled == startOverEnabled &&
        other.graceDaysSpent == graceDaysSpent &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        targetDays.hashCode ^
        startDate.hashCode ^
        _days.hashCode ^
        lastCompletedDate.hashCode ^
        isArchived.hashCode ^
        startOverEnabled.hashCode ^
        graceDaysSpent.hashCode ^
        createdAt.hashCode;
  }
}

extension ChallengeModelX on ChallengeModel {
  static ChallengeModel empty() => ChallengeModel(
        id: const Uuid().v4(),
        title: '',
        targetDays: 0,
        startDate: DateTime(0),
        days: const [],
        graceDaysSpent: 0,
        numberOfAttempts: 1,
        createdAt: DateTime.now(),
      );

  bool isDayCompleted({required DateTime date}) {
    return _days.any(
      (day) =>
          day.isCompleted && day.date.year == date.year && day.date.month == date.month && day.date.day == date.day,
    );
  }

  int get bestStreak {
    if (_days.isEmpty) return 0;

    var currentStreak = 0;
    var maxStreak = 0;
    final sortedDays = List<DayModel>.from(_days)..sort((DayModel a, DayModel b) => a.date.compareTo(b.date));

    for (final day in sortedDays) {
      if (day.isCompleted) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else {
        currentStreak = 0;
      }
    }

    return maxStreak;
  }

  int get currentStreak {
    if (_days.isEmpty) return 0;
    var currentStreak = 0;
    final sortedDays = List<DayModel>.from(_days)..sort((DayModel a, DayModel b) => a.date.compareTo(b.date));

    for (final day in sortedDays) {
      if (day.isCompleted) {
        currentStreak++;
      }
    }
    return currentStreak;
  }

  bool get areGraceDaysSpent => graceDaysSpent >= ChallengeModel.maxGraceDayCount;

  bool get isYesterdayCompleted => _days.any(
        (day) =>
            day.date.withoutTime == DateTime.now().subtract(const Duration(days: 1)).withoutTime && day.isCompleted,
      );

  bool get isYesterdaySkipped => _days.any(
        (day) => day.date.withoutTime == DateTime.now().subtract(const Duration(days: 1)).withoutTime && day.isSkipped,
      );

  // List<DayModel> get sortedDays => List<DayModel>.from(days)
  //     ..sort((DayModel a, DayModel b) => a.date.compareTo(b.date));
}

enum DayStatus {
  completed,
  skipped,
  none,
}

@immutable
class DayModel {
  const DayModel({
    required this.date,
    required this.status,
  });

  factory DayModel.fromMap(Map<String, dynamic> map) {
    return DayModel(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      status: DayStatus.values.firstWhere((e) => e.name == map['status']),
    );
  }

  factory DayModel.fromJson(String source) => DayModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final DateTime date;
  final DayStatus status;

  DayModel copyWith({
    DateTime? date,
    DayStatus? status,
  }) {
    return DayModel(
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'status': status.name,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'DayModel(date: $date, status: $status)';

  @override
  bool operator ==(covariant DayModel other) {
    if (identical(this, other)) return true;

    return other.date == date && other.status == status;
  }

  @override
  int get hashCode => date.hashCode ^ status.hashCode;
}

extension DayModelX on DayModel {
  bool get isCompleted => status == DayStatus.completed;
  bool get isSkipped => status == DayStatus.skipped;
  bool get isNone => status == DayStatus.none;
}
