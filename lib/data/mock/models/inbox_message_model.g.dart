// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InboxMessageModelAdapter extends TypeAdapter<InboxMessageModel> {
  @override
  final int typeId = 19;

  @override
  InboxMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InboxMessageModel(
      id: fields[0] as String,
      service: fields[1] as String,
      sender: fields[2] as String,
      subject: fields[3] as String,
      preview: fields[4] as String,
      receivedAt: fields[5] as DateTime,
      isRead: fields[6] as bool,
      isStarred: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, InboxMessageModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.service)
      ..writeByte(2)
      ..write(obj.sender)
      ..writeByte(3)
      ..write(obj.subject)
      ..writeByte(4)
      ..write(obj.preview)
      ..writeByte(5)
      ..write(obj.receivedAt)
      ..writeByte(6)
      ..write(obj.isRead)
      ..writeByte(7)
      ..write(obj.isStarred);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InboxMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
