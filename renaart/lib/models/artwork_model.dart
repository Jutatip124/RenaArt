import 'package:hive/hive.dart';

part 'artwork_model.g.dart';

/// Week 3 Data Model (API_RESPONSE.json entity — exact fields from lab sheet)
@HiveType(typeId: 0)
class Artwork extends HiveObject {
  @HiveField(0)
  final String id; // objectID

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist; // artistDisplayName

  @HiveField(3)
  final String artistId;

  @HiveField(4)
  final String year; // objectDate

  @HiveField(5)
  final String period;

  @HiveField(6)
  final String medium;

  @HiveField(7)
  final String dimensions;

  @HiveField(8)
  final String location; // repository

  @HiveField(9)
  final String imageUrl; // primaryImage

  @HiveField(10)
  final String thumbnailUrl; // primaryImageSmall / web-large

  @HiveField(11)
  final String description;

  @HiveField(12)
  final String historicalContext;

  @HiveField(13)
  final String meaning;

  @HiveField(14)
  final List<String> keySymbols;

  @HiveField(15)
  final List<String> relatedArtworkIds;

  @HiveField(16)
  final String department;

  @HiveField(17)
  final bool isPublicDomain;

  @HiveField(18)
  final String subject;

  Artwork({
    required this.id,
    required this.title,
    this.artist = 'Unknown Artist',
    this.artistId = '',
    this.year = '',
    this.period = 'Renaissance',
    this.medium = '',
    this.dimensions = '',
    this.location = '',
    required this.imageUrl,
    required this.thumbnailUrl,
    this.description = '',
    this.historicalContext = '',
    this.meaning = '',
    this.keySymbols = const [],
    this.relatedArtworkIds = const [],
    this.department = 'European Paintings',
    this.isPublicDomain = true,
    this.subject = 'Religious',
  });

  /// Factory: parse from bundled assets/data/artworks.json
  /// Instant load — no network. All images from Wikimedia Commons (public domain).
  factory Artwork.fromLocalJson(Map<String, dynamic> json) {
    final year = json['year'] as int? ?? 0;
    final symbols = json['keySymbols'];
    return Artwork(
      id: (json['id'] as String? ?? '').isNotEmpty
          ? json['id'] as String
          : 'local_${json['title']}',
      title: (json['title'] as String? ?? 'Untitled').trim(),
      artist: (json['artist'] as String? ?? 'Unknown Artist').trim(),
      artistId: '',
      year: year > 0 ? year.toString() : '',
      period: (json['period'] as String? ?? 'Renaissance').trim(),
      medium: (json['medium'] as String? ?? '').trim(),
      dimensions: (json['dimensions'] as String? ?? '').trim(),
      location: (json['origin'] as String? ?? '').trim(),
      imageUrl: (json['imageUrl'] as String? ?? '').trim(),
      thumbnailUrl: (json['thumbnailUrl'] as String? ?? json['imageUrl'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      historicalContext: (json['historicalContext'] as String? ?? '').trim(),
      meaning: (json['meaning'] as String? ?? '').trim(),
      keySymbols: symbols is List ? symbols.cast<String>() : const [],
      relatedArtworkIds: const [],
      department: (json['type'] as String? ?? 'Painting'),
      isPublicDomain: (json['isPublicDomain'] as bool?) ?? true,
      subject: (json['subject'] as String? ?? 'Religious').trim(),
    );
  }

  @override
  String toString() => 'Artwork($id: $title by $artist)';
}

/// Week 3: USER_ARTWORK_STATE.json entity stored in Hive
@HiveType(typeId: 1)
class UserArtworkState extends HiveObject {
  @HiveField(0)
  final String artworkId;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  bool isFavorited;

  @HiveField(3)
  String? favoritedDate;

  @HiveField(4)
  String? lastViewed;

  @HiveField(5)
  int viewCount;

  @HiveField(6)
  String? notes;

  UserArtworkState({
    required this.artworkId,
    required this.userId,
    this.isFavorited = false,
    this.favoritedDate,
    this.lastViewed,
    this.viewCount = 0,
    this.notes,
  });
}

/// Week 3: OFFLINE_ARTWORK.json entity stored in FileSystem + Hive
@HiveType(typeId: 2)
class OfflineArtwork extends HiveObject {
  @HiveField(0)
  final String artworkId;

  @HiveField(1)
  final String deviceId;

  @HiveField(2)
  bool isOfflineAvailable;

  @HiveField(3)
  final String downloadedDate;

  @HiveField(4)
  String localImagePath;

  @HiveField(5)
  double originalFileSizeMB;

  @HiveField(6)
  double resizedFileSizeMB;

  @HiveField(7)
  String imageResolution; // e.g. "1080x1440"

  @HiveField(8)
  String? lastAccessDate;

  OfflineArtwork({
    required this.artworkId,
    this.deviceId = '',
    this.isOfflineAvailable = true,
    required this.downloadedDate,
    this.localImagePath = '',
    this.originalFileSizeMB = 0,
    this.resizedFileSizeMB = 0,
    this.imageResolution = '1080x1080',
    this.lastAccessDate,
  });
}
