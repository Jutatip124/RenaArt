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
  });

  /// Factory: parse from Met Museum API response (Week 3: Part 3)
  factory Artwork.fromMetApi(Map<String, dynamic> json) {
    return Artwork(
      id: json['objectID'].toString(),
      title: (json['title'] as String?)?.trim().isEmpty == true
          ? 'Untitled'
          : (json['title'] as String?) ?? 'Untitled',
      artist: json['artistDisplayName'] as String? ?? 'Unknown Artist',
      artistId: json['artistULAN_URL'] as String? ?? '',
      year: json['objectDate'] as String? ?? '',
      period: _parsePeriod(
        json['period'] as String?,
        json['objectDate'] as String?,
        json['culture'] as String?,
      ),
      medium: json['medium'] as String? ?? '',
      dimensions: json['dimensions'] as String? ?? '',
      location: json['repository'] as String? ?? '',
      imageUrl: json['primaryImage'] as String? ?? '',
      thumbnailUrl: json['primaryImageSmall'] as String? ??
          json['primaryImage'] as String? ??
          '',
      description: _buildDescription(json),
      historicalContext: json['period'] as String? ?? json['culture'] as String? ?? '',
      department: json['department'] as String? ?? 'European Paintings',
      isPublicDomain: json['isPublicDomain'] as bool? ?? false,
      keySymbols: (json['tags'] as List<dynamic>?)
              ?.map((t) => t['term'] as String)
              .toList() ??
          [],
    );
  }

  static String _buildDescription(Map<String, dynamic> json) {
    final title = json['title'] ?? 'This work';
    final artist = json['artistDisplayName'] ?? 'an unknown artist';
    final date = json['objectDate'] ?? '';
    final dept = json['department'] ?? '';
    final repo = json['repository'] ?? '';

    return '$title is a work by $artist${date.isNotEmpty ? ', created $date' : ''}.'
        '${dept.isNotEmpty ? ' Part of the $dept collection.' : ''}'
        '${repo.isNotEmpty ? ' Currently housed at $repo.' : ''}';
  }

  static String _parsePeriod(String? period, String? date, String? culture) {
    final raw = [period, date, culture]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ')
        .toLowerCase();

    if (raw.contains('northern')) return 'Northern Renaissance';
    if (raw.contains('flemish')) return 'Flemish';
    if (raw.contains('manner')) return 'Mannerism';
    if (raw.contains('high')) return 'High Renaissance';
    if (raw.contains('early')) return 'Early Renaissance';
    // Guess from century
    if (raw.contains('15th') || raw.contains('1400') || raw.contains('1480') ||
        raw.contains('1490')) return 'Early Renaissance';
    if (raw.contains('16th') || raw.contains('1500') || raw.contains('1510') ||
        raw.contains('1520')) return 'High Renaissance';
    return 'Renaissance';
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
