// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meditation_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeditationSessionModelAdapter
    extends TypeAdapter<MeditationSessionModel> {
  @override
  final int typeId = 10;

  @override
  MeditationSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeditationSessionModel(
      id: fields[0] as String,
      type: fields[1] as MeditationType,
      startTime: fields[2] as DateTime,
      durationMinutes: fields[3] as int,
      isCompleted: fields[4] as bool,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MeditationSessionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeditationTypeAdapter extends TypeAdapter<MeditationType> {
  @override
  final int typeId = 9;

  @override
  MeditationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MeditationType.breathing;
      case 1:
        return MeditationType.guided;
      case 2:
        return MeditationType.unguided;
      case 3:
        return MeditationType.sleep;
      case 4:
        return MeditationType.focus;
      default:
        return MeditationType.breathing;
    }
  }

  @override
  void write(BinaryWriter writer, MeditationType obj) {
    switch (obj) {
      case MeditationType.breathing:
        writer.writeByte(0);
        break;
      case MeditationType.guided:
        writer.writeByte(1);
        break;
      case MeditationType.unguided:
        writer.writeByte(2);
        break;
      case MeditationType.sleep:
        writer.writeByte(3);
        break;
      case MeditationType.focus:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
