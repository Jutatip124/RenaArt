// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter packages pub run build_runner build

part of 'artwork_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArtworkAdapter extends TypeAdapter<Artwork> {
  @override
  final int typeId = 0;

  @override
  Artwork read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Artwork(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      year: fields[3] as String,
      period: fields[4] as String,
      medium: fields[5] as String,
      dimensions: fields[6] as String?,
      location: fields[7] as String?,
      imageUrl: fields[8] as String,
      thumbnailUrl: fields[9] as String,
      description: fields[10] as String,
      historicalContext: fields[11] as String?,
      meaning: fields[12] as String?,
      keySymbols: (fields[13] as List).cast<String>(),
      relatedArtworkIds: (fields[14] as List).cast<String>(),
      department: fields[15] as String,
      isPublicDomain: fields[16] as bool,
      aspectRatio: fields[17] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Artwork obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.period)
      ..writeByte(5)
      ..write(obj.medium)
      ..writeByte(6)
      ..write(obj.dimensions)
      ..writeByte(7)
      ..write(obj.location)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.thumbnailUrl)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.historicalContext)
      ..writeByte(12)
      ..write(obj.meaning)
      ..writeByte(13)
      ..write(obj.keySymbols)
      ..writeByte(14)
      ..write(obj.relatedArtworkIds)
      ..writeByte(15)
      ..write(obj.department)
      ..writeByte(16)
      ..write(obj.isPublicDomain)
      ..writeByte(17)
      ..write(obj.aspectRatio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
