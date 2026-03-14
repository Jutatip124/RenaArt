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
    final rawYear = json['year'];
    final year = rawYear is num ? rawYear.toInt() : (int.tryParse('$rawYear') ?? 0);
    final symbols = json['keySymbols'];
    return Artwork(
      id: _str(json['id']).isNotEmpty ? _str(json['id']) : 'local_${json['title']}',
      title: _str(json['title'], 'Untitled'),
      artist: _str(json['artist'], 'Unknown Artist'),
      artistId: '',
      year: year > 0 ? year.toString() : '',
      period: _str(json['period'], 'Renaissance'),
      medium: _str(json['medium']),
      dimensions: _str(json['dimensions']),
      location: _str(json['origin']),
      imageUrl: _str(json['imageUrl']),
      thumbnailUrl: _str(json['thumbnailUrl']).isNotEmpty
          ? _str(json['thumbnailUrl'])
          : _str(json['imageUrl']),
      description: _str(json['description']),
      historicalContext: _str(json['historicalContext']),
      meaning: _str(json['meaning']),
      keySymbols: symbols is List
          ? symbols.map((e) => '$e').toList()
          : const [],
      relatedArtworkIds: const [],
      department: _str(json['type'], 'Painting'),
      isPublicDomain: json['isPublicDomain'] == true,
      subject: _str(json['subject'], 'Religious'),
    );
  }

  /// Safely extract a trimmed string from a dynamic value.
  static String _str(dynamic v, [String fallback = '']) =>
      (v is String ? v : (v?.toString() ?? fallback)).trim();

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
