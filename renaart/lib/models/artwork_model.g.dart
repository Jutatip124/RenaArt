// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'artwork_model.dart';

// ─── ArtworkAdapter ───────────────────────────────────────────────────────────
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
      artistId: fields[3] as String,
      year: fields[4] as String,
      period: fields[5] as String,
      medium: fields[6] as String,
      dimensions: fields[7] as String,
      location: fields[8] as String,
      imageUrl: fields[9] as String,
      thumbnailUrl: fields[10] as String,
      description: fields[11] as String,
      historicalContext: fields[12] as String,
      meaning: fields[13] as String,
      keySymbols: (fields[14] as List).cast<String>(),
      relatedArtworkIds: (fields[15] as List).cast<String>(),
      department: fields[16] as String,
      isPublicDomain: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Artwork obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.artist)
      ..writeByte(3)..write(obj.artistId)
      ..writeByte(4)..write(obj.year)
      ..writeByte(5)..write(obj.period)
      ..writeByte(6)..write(obj.medium)
      ..writeByte(7)..write(obj.dimensions)
      ..writeByte(8)..write(obj.location)
      ..writeByte(9)..write(obj.imageUrl)
      ..writeByte(10)..write(obj.thumbnailUrl)
      ..writeByte(11)..write(obj.description)
      ..writeByte(12)..write(obj.historicalContext)
      ..writeByte(13)..write(obj.meaning)
      ..writeByte(14)..write(obj.keySymbols)
      ..writeByte(15)..write(obj.relatedArtworkIds)
      ..writeByte(16)..write(obj.department)
      ..writeByte(17)..write(obj.isPublicDomain);
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

// ─── UserArtworkStateAdapter ──────────────────────────────────────────────────
class UserArtworkStateAdapter extends TypeAdapter<UserArtworkState> {
  @override
  final int typeId = 1;

  @override
  UserArtworkState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserArtworkState(
      artworkId: fields[0] as String,
      userId: fields[1] as String,
      isFavorited: fields[2] as bool,
      favoritedDate: fields[3] as String?,
      lastViewed: fields[4] as String?,
      viewCount: fields[5] as int,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserArtworkState obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.artworkId)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.isFavorited)
      ..writeByte(3)..write(obj.favoritedDate)
      ..writeByte(4)..write(obj.lastViewed)
      ..writeByte(5)..write(obj.viewCount)
      ..writeByte(6)..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserArtworkStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// ─── OfflineArtworkAdapter ────────────────────────────────────────────────────
class OfflineArtworkAdapter extends TypeAdapter<OfflineArtwork> {
  @override
  final int typeId = 2;

  @override
  OfflineArtwork read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineArtwork(
      artworkId: fields[0] as String,
      deviceId: fields[1] as String,
      isOfflineAvailable: fields[2] as bool,
      downloadedDate: fields[3] as String,
      localImagePath: fields[4] as String,
      originalFileSizeMB: fields[5] as double,
      resizedFileSizeMB: fields[6] as double,
      imageResolution: fields[7] as String,
      lastAccessDate: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineArtwork obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.artworkId)
      ..writeByte(1)..write(obj.deviceId)
      ..writeByte(2)..write(obj.isOfflineAvailable)
      ..writeByte(3)..write(obj.downloadedDate)
      ..writeByte(4)..write(obj.localImagePath)
      ..writeByte(5)..write(obj.originalFileSizeMB)
      ..writeByte(6)..write(obj.resizedFileSizeMB)
      ..writeByte(7)..write(obj.imageResolution)
      ..writeByte(8)..write(obj.lastAccessDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineArtworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
