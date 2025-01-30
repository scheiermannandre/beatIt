// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeDtoAdapter extends TypeAdapter<ChallengeDto> {
  @override
  final int typeId = 0;

  @override
  ChallengeDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeDto(
      id: fields[0] as String,
      title: fields[1] as String,
      targetDays: fields[2] as int,
      startDate: fields[3] as DateTime,
      days: (fields[4] as List).cast<DayDto>(),
      lastCompletedDate: fields[5] as DateTime?,
      isArchived: fields[6] as bool,
      startOverEnabled: fields[7] as bool,
      graceDaysSpent: fields[8] as int,
      createdAt: fields[9] as DateTime,
      numberOfAttempts: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeDto obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetDays)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.days)
      ..writeByte(5)
      ..write(obj.lastCompletedDate)
      ..writeByte(6)
      ..write(obj.isArchived)
      ..writeByte(7)
      ..write(obj.startOverEnabled)
      ..writeByte(8)
      ..write(obj.graceDaysSpent)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.numberOfAttempts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayDtoAdapter extends TypeAdapter<DayDto> {
  @override
  final int typeId = 1;

  @override
  DayDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayDto(
      date: fields[0] as DateTime,
      status: fields[1] as DayStatusDto,
    );
  }

  @override
  void write(BinaryWriter writer, DayDto obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayStatusDtoAdapter extends TypeAdapter<DayStatusDto> {
  @override
  final int typeId = 2;

  @override
  DayStatusDto read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DayStatusDto.completed;
      case 1:
        return DayStatusDto.skipped;
      case 2:
        return DayStatusDto.none;
      default:
        return DayStatusDto.completed;
    }
  }

  @override
  void write(BinaryWriter writer, DayStatusDto obj) {
    final _ = switch (obj) {
      DayStatusDto.completed => writer.writeByte(0),
      DayStatusDto.skipped => writer.writeByte(1),
      DayStatusDto.none => writer.writeByte(2)
    };
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayStatusDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
