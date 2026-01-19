// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActorAdapter extends TypeAdapter<Actor> {
  @override
  final int typeId = 1;

  @override
  Actor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Actor(
      id: fields[0] as String,
      name: fields[1] as String,
      profileUrl: fields[2] as String?,
      characterName: fields[3] as String?,
      role: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Actor obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.profileUrl)
      ..writeByte(3)
      ..write(obj.characterName)
      ..writeByte(4)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
