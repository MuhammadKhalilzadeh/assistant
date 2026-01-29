// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepRecordModelAdapter extends TypeAdapter<SleepRecordModel> {
  @override
  final int typeId = 4;

  @override
  SleepRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepRecordModel(
      id: fields[0] as String,
      bedTime: fields[1] as DateTime,
      wakeTime: fields[2] as DateTime,
      quality: fields[3] as SleepQuality,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SleepRecordModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bedTime)
      ..writeByte(2)
      ..write(obj.wakeTime)
      ..writeByte(3)
      ..write(obj.quality)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SleepQualityAdapter extends TypeAdapter<SleepQuality> {
  @override
  final int typeId = 3;

  @override
  SleepQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SleepQuality.poor;
      case 1:
        return SleepQuality.fair;
      case 2:
        return SleepQuality.good;
      case 3:
        return SleepQuality.excellent;
      default:
        return SleepQuality.poor;
    }
  }

  @override
  void write(BinaryWriter writer, SleepQuality obj) {
    switch (obj) {
      case SleepQuality.poor:
        writer.writeByte(0);
        break;
      case SleepQuality.fair:
        writer.writeByte(1);
        break;
      case SleepQuality.good:
        writer.writeByte(2);
        break;
      case SleepQuality.excellent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
