import 'package:beat_it/features/challenge/challenge.dart';
import 'package:hive/hive.dart';

part 'challenge_dto.g.dart';

@HiveType(typeId: 0)
class ChallengeDto extends HiveObject {
  ChallengeDto({
    required this.id,
    required this.title,
    required this.targetDays,
    required this.startDate,
    required this.days,
    required this.lastCompletedDate,
    required this.isArchived,
    required this.startOverEnabled,
    required this.graceDaysSpent,
    required this.createdAt,
    required this.numberOfAttempts,
  });

  factory ChallengeDto.fromModel(ChallengeModel model) {
    return ChallengeDto(
      id: model.id,
      title: model.title,
      targetDays: model.targetDays,
      startDate: model.startDate,
      days: model.days.map(DayDto.fromModel).toList(),
      lastCompletedDate: model.lastCompletedDate,
      isArchived: model.isArchived ?? false,
      graceDaysSpent: model.graceDaysSpent,
      startOverEnabled: model.startOverEnabled,
      createdAt: model.createdAt,
      numberOfAttempts: model.numberOfAttempts,
    );
  }

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int targetDays;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final List<DayDto> days;

  @HiveField(5)
  final DateTime? lastCompletedDate;

  @HiveField(6)
  final bool isArchived;

  @HiveField(7)
  final bool startOverEnabled;

  @HiveField(8)
  final int graceDaysSpent;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final int numberOfAttempts;

  ChallengeModel toModel() {
    return ChallengeModel(
      id: id,
      title: title,
      targetDays: targetDays,
      startDate: startDate,
      days: days.map((dto) => dto.toModel()).toList(),
      lastCompletedDate: lastCompletedDate,
      isArchived: isArchived,
      startOverEnabled: startOverEnabled,
      graceDaysSpent: graceDaysSpent,
      createdAt: createdAt,
      numberOfAttempts: numberOfAttempts,
    );
  }
}

@HiveType(typeId: 1)
class DayDto extends HiveObject {
  DayDto({
    required this.date,
    required this.status,
  });

  factory DayDto.fromModel(DayModel model) {
    return DayDto(
      date: model.date,
      status: DayStatusDto.values.firstWhere((e) => e.name == model.status.name),
    );
  }

  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final DayStatusDto status;

  DayModel toModel() {
    return DayModel(
      date: date,
      status: DayStatus.values.firstWhere((e) => e.name == status.name),
    );
  }
}

@HiveType(typeId: 2)
enum DayStatusDto {
  @HiveField(0)
  completed,
  @HiveField(1)
  skipped,
  @HiveField(2)
  none,
}
