// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heart_rate_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HeartRateRecordModelAdapter extends TypeAdapter<HeartRateRecordModel> {
  @override
  final int typeId = 6;

  @override
  HeartRateRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HeartRateRecordModel(
      id: fields[0] as String,
      bpm: fields[1] as int,
      recordedAt: fields[2] as DateTime,
      zone: fields[3] as HeartRateZone?,
    );
  }

  @override
  void write(BinaryWriter writer, HeartRateRecordModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bpm)
      ..writeByte(2)
      ..write(obj.recordedAt)
      ..writeByte(3)
      ..write(obj.zone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeartRateRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HeartRateZoneAdapter extends TypeAdapter<HeartRateZone> {
  @override
  final int typeId = 5;

  @override
  HeartRateZone read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HeartRateZone.resting;
      case 1:
        return HeartRateZone.warmUp;
      case 2:
        return HeartRateZone.fatBurn;
      case 3:
        return HeartRateZone.cardio;
      case 4:
        return HeartRateZone.peak;
      default:
        return HeartRateZone.resting;
    }
  }

  @override
  void write(BinaryWriter writer, HeartRateZone obj) {
    switch (obj) {
      case HeartRateZone.resting:
        writer.writeByte(0);
        break;
      case HeartRateZone.warmUp:
        writer.writeByte(1);
        break;
      case HeartRateZone.fatBurn:
        writer.writeByte(2);
        break;
      case HeartRateZone.cardio:
        writer.writeByte(3);
        break;
      case HeartRateZone.peak:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeartRateZoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
