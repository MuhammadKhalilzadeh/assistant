// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoodEntryModelAdapter extends TypeAdapter<MoodEntryModel> {
  @override
  final int typeId = 2;

  @override
  MoodEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntryModel(
      id: fields[0] as String,
      mood: fields[1] as MoodLevel,
      recordedAt: fields[2] as DateTime,
      notes: fields[3] as String?,
      activities: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mood)
      ..writeByte(2)
      ..write(obj.recordedAt)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.activities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodLevelAdapter extends TypeAdapter<MoodLevel> {
  @override
  final int typeId = 1;

  @override
  MoodLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodLevel.great;
      case 1:
        return MoodLevel.good;
      case 2:
        return MoodLevel.okay;
      case 3:
        return MoodLevel.bad;
      case 4:
        return MoodLevel.awful;
      default:
        return MoodLevel.great;
    }
  }

  @override
  void write(BinaryWriter writer, MoodLevel obj) {
    switch (obj) {
      case MoodLevel.great:
        writer.writeByte(0);
        break;
      case MoodLevel.good:
        writer.writeByte(1);
        break;
      case MoodLevel.okay:
        writer.writeByte(2);
        break;
      case MoodLevel.bad:
        writer.writeByte(3);
        break;
      case MoodLevel.awful:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
