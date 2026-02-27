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

  /// Factory: parse from bundled assets/data/artworks.json
  /// Instant load — no network. All images from Wikimedia Commons (public domain).
  factory Artwork.fromLocalJson(Map<String, dynamic> json) {
    final year = json['year'] as int? ?? 0;
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
      historicalContext: '',
      meaning: '',
      keySymbols: const [],
      relatedArtworkIds: const [],
      department: (json['type'] as String? ?? 'Painting'),
      isPublicDomain: (json['isPublicDomain'] as bool?) ?? true,
    );
  }

  /// Factory: parse from Art Institute of Chicago API response
  /// AIC returns full objects in one search call — no batching needed
  factory Artwork.fromAicApi(Map<String, dynamic> json) {
    final imageId = (json['image_id'] as String?)?.trim() ?? '';
    const base = 'https://www.artic.edu/iiif/2';
    final imageUrl   = imageId.isNotEmpty ? '$base/$imageId/full/843,/0/default.jpg' : '';
    final thumbUrl   = imageId.isNotEmpty ? '$base/$imageId/full/400,/0/default.jpg' : '';

    // Parse artist: AIC gives "Artist Name\nNationality, birth–death"
    final artistRaw  = (json['artist_display'] as String? ?? '').split('\n').first.trim();
    final title      = (json['title'] as String?)?.trim() ?? 'Untitled';
    final dateStr    = (json['date_display'] as String?) ?? '';
    final dateStart  = json['date_start'] as int?;
    final dateEnd    = json['date_end'] as int?;
    final medium     = (json['medium_display'] as String?) ?? '';
    final dimensions = (json['dimensions'] as String?) ?? '';
    final place      = (json['place_of_origin'] as String?) ?? '';
    final dept       = (json['department_title'] as String?) ?? 'European Art';
    final isPublic   = json['is_public_domain'] as bool? ?? false;

    final tags = <String>[];
    final subjects = json['subject_titles'];
    if (subjects is List) tags.addAll(subjects.cast<String>().take(5));

    return Artwork(
      id: 'aic_${json['id']}',
      title: title,
      artist: artistRaw.isEmpty ? 'Unknown Artist' : artistRaw,
      year: dateStr,
      period: _parsePeriodFromYear(dateStart, dateEnd,
          json['style_title'] as String?, json['classification_title'] as String?),
      medium: medium,
      dimensions: dimensions,
      location: place.isNotEmpty ? place : 'Art Institute of Chicago',
      imageUrl: imageUrl,
      thumbnailUrl: thumbUrl,
      description: _buildAicDescription(title, artistRaw, dateStr, dept, place),
      historicalContext: dept,
      department: dept,
      isPublicDomain: isPublic,
      keySymbols: tags,
    );
  }

  /// Factory: parse from Rijksmuseum API response
  factory Artwork.fromRijksApi(Map<String, dynamic> json) {
    final webImage   = json['webImage'] as Map<String, dynamic>?;
    final imageUrl   = (webImage?['url'] as String? ?? '').replaceAll('=s0', '=s1080');
    final thumbUrl   = (webImage?['url'] as String? ?? '').replaceAll('=s0', '=s400');
    final dating     = json['dating'] as Map<String, dynamic>?;
    final yearEarly  = dating?['yearEarly'] as int?;
    final yearLate   = dating?['yearLate'] as int?;
    final dateStr    = (dating?['presentingDate'] as String?) ?? '';
    final artistRaw  = (json['principalOrFirstMaker'] as String?) ?? 'Unknown Artist';
    final title      = (json['title'] as String?)?.trim() ?? 'Untitled';
    final objNum     = (json['objectNumber'] as String?) ?? '';

    return Artwork(
      id: 'rijks_$objNum',
      title: title,
      artist: artistRaw,
      year: dateStr,
      period: _parsePeriodFromYear(yearEarly, yearLate, null, null),
      medium: (json['objectTypes'] as List?)?.cast<String>().join(', ') ?? '',
      dimensions: '',
      location: 'Rijksmuseum, Amsterdam',
      imageUrl: imageUrl,
      thumbnailUrl: thumbUrl,
      description: _buildRijksDescription(title, artistRaw, dateStr),
      historicalContext: 'Dutch / Flemish Renaissance Collection',
      department: 'Dutch and Flemish Art',
      isPublicDomain: true,
      keySymbols: (json['productionPlaces'] as List?)?.cast<String>() ?? [],
    );
  }

  static String _parsePeriodFromYear(
      int? start, int? end, String? style, String? classification) {
    final raw = [style, classification]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ')
        .toLowerCase();
    if (raw.contains('northern')) return 'Northern Renaissance';
    if (raw.contains('flemish') || raw.contains('dutch')) return 'Flemish';
    if (raw.contains('manism') || raw.contains('mannerism')) return 'Mannerism';
    if (raw.contains('high renaissance')) return 'High Renaissance';
    if (raw.contains('early renaissance')) return 'Early Renaissance';

    final year = start ?? end;
    if (year != null) {
      if (year >= 1400 && year <= 1499) return 'Early Renaissance';
      if (year >= 1500 && year <= 1529) return 'High Renaissance';
      if (year >= 1530 && year <= 1625) return 'Mannerism';
      if (year >= 1400 && year <= 1625) return 'Renaissance';
    }
    return 'Other';
  }

  static String _buildAicDescription(String title, String artist,
      String date, String dept, String place) {
    return '$title${artist.isNotEmpty && artist != 'Unknown Artist' ? ' by $artist' : ''}'
        '${date.isNotEmpty ? ', $date' : ''}.'
        '${dept.isNotEmpty ? ' $dept collection.' : ''}'
        '${place.isNotEmpty ? ' Origin: $place.' : ''}';
  }

  static String _buildRijksDescription(
      String title, String artist, String date) {
    return '$title${artist.isNotEmpty ? ' by $artist' : ''}'
        '${date.isNotEmpty ? ', $date' : ''}.'
        ' Rijksmuseum, Amsterdam.';
  }

  /// Factory: parse from Met Museum API response (Week 3: Part 3)
  factory Artwork.fromMetApi(Map<String, dynamic> json) {
    final primaryImage = _sanitizeImageUrl(json['primaryImage'] as String?);
    final primaryImageSmall = _sanitizeImageUrl(
      json['primaryImageSmall'] as String?,
    );

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
      imageUrl: primaryImage.isNotEmpty ? primaryImage : primaryImageSmall,
      thumbnailUrl: primaryImageSmall.isNotEmpty
          ? primaryImageSmall
          : primaryImage,
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

  static String _sanitizeImageUrl(String? rawUrl) {
    final url = (rawUrl ?? '').trim();
    if (url.isEmpty) return '';
    return url.startsWith('http://')
        ? url.replaceFirst('http://', 'https://')
        : url;
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

    final year = _extractYear(raw);
    if (year != null) {
      if (year >= 1400 && year <= 1499) return 'Early Renaissance';
      if (year >= 1500 && year <= 1529) return 'High Renaissance';
      if (year >= 1530 && year <= 1625) return 'Mannerism';
    }

    if (raw.contains('renaissance')) return 'Renaissance';
    return 'Other';
  }

  static int? _extractYear(String raw) {
    final matches = RegExp(r'(\d{4})').allMatches(raw);
    for (final match in matches) {
      final year = int.tryParse(match.group(1)!);
      if (year != null && year > 1000 && year < 2100) {
        return year;
      }
    }
    return null;
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
