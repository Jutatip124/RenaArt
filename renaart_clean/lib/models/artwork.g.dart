// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artwork.dart';

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
      objectId: fields[0] as String,
      title: fields[1] as String,
      artistName: fields[2] as String,
      artistBio: fields[3] as String?,
      objectDate: fields[4] as String,
      medium: fields[5] as String?,
      dimensions: fields[6] as String?,
      department: fields[7] as String?,
      imageUrl: fields[8] as String?,
      thumbnailUrl: fields[9] as String?,
      culture: fields[10] as String?,
      period: fields[11] as String?,
      creditLine: fields[12] as String?,
      accessionYear: fields[13] as String?,
      isPublicDomain: fields[14] as bool,
      isFavorited: fields[15] as bool,
      isOfflineSaved: fields[16] as bool,
      savedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Artwork obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.objectId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artistName)
      ..writeByte(3)
      ..write(obj.artistBio)
      ..writeByte(4)
      ..write(obj.objectDate)
      ..writeByte(5)
      ..write(obj.medium)
      ..writeByte(6)
      ..write(obj.dimensions)
      ..writeByte(7)
      ..write(obj.department)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.thumbnailUrl)
      ..writeByte(10)
      ..write(obj.culture)
      ..writeByte(11)
      ..write(obj.period)
      ..writeByte(12)
      ..write(obj.creditLine)
      ..writeByte(13)
      ..write(obj.accessionYear)
      ..writeByte(14)
      ..write(obj.isPublicDomain)
      ..writeByte(15)
      ..write(obj.isFavorited)
      ..writeByte(16)
      ..write(obj.isOfflineSaved)
      ..writeByte(17)
      ..write(obj.savedAt);
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
