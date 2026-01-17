// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: fields[0] as String,
      tmdbId: fields[1] as int,
      title: fields[2] as String,
      description: fields[3] as String?,
      posterUrl: fields[4] as String?,
      backdropUrl: fields[5] as String?,
      s3VideoUrl: fields[6] as String,
      duration: fields[7] as int?,
      releaseDate: fields[8] as DateTime?,
      rating: fields[9] as double?,
      genres: (fields[10] as List).cast<String>(),
      createdAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tmdbId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.posterUrl)
      ..writeByte(5)
      ..write(obj.backdropUrl)
      ..writeByte(6)
      ..write(obj.s3VideoUrl)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.releaseDate)
      ..writeByte(9)
      ..write(obj.rating)
      ..writeByte(10)
      ..write(obj.genres)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
