// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AlarmItem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmItemAdapter extends TypeAdapter<AlarmItem> {
  @override
  final int typeId = 1;

  @override
  AlarmItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmItem(
      desc: fields[0] as String,
      type: fields[1] as int,
      startTime: fields[2] as String,
      endTime: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.desc)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
