// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StepRecordModelAdapter extends TypeAdapter<StepRecordModel> {
  @override
  final int typeId = 11;

  @override
  StepRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StepRecordModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      steps: fields[2] as int,
      goal: fields[3] as int,
      distanceKm: fields[4] as double,
      caloriesBurned: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StepRecordModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.goal)
      ..writeByte(4)
      ..write(obj.distanceKm)
      ..writeByte(5)
      ..write(obj.caloriesBurned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
