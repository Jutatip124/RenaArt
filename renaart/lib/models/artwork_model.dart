import 'package:hive/hive.dart';

part 'artwork_model.g.dart';

@HiveType(typeId: 0)
class Artwork extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String year;

  @HiveField(4)
  final String period;

  @HiveField(5)
  final String medium;

  @HiveField(6)
  final String? dimensions;

  @HiveField(7)
  final String? location;

  @HiveField(8)
  final String imageUrl;

  @HiveField(9)
  final String thumbnailUrl;

  @HiveField(10)
  final String description;

  @HiveField(11)
  final String? historicalContext;

  @HiveField(12)
  final String? meaning;

  @HiveField(13)
  final List<String> keySymbols;

  @HiveField(14)
  final List<String> relatedArtworkIds;

  @HiveField(15)
  final String department;

  @HiveField(16)
  final bool isPublicDomain;

  @HiveField(17)
  final double? aspectRatio; // width/height for masonry layout

  Artwork({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.period,
    required this.medium,
    this.dimensions,
    this.location,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.description,
    this.historicalContext,
    this.meaning,
    this.keySymbols = const [],
    this.relatedArtworkIds = const [],
    this.department = 'European Paintings',
    this.isPublicDomain = true,
    this.aspectRatio,
  });

  factory Artwork.fromMetApi(Map<String, dynamic> json) {
    final primaryImage = json['primaryImage'] as String? ?? '';
    final primaryImageSmall =
        json['primaryImageSmall'] as String? ?? primaryImage;

    return Artwork(
      id: json['objectID'].toString(),
      title: json['title'] as String? ?? 'Untitled',
      artist: json['artistDisplayName'] as String? ?? 'Unknown Artist',
      year: json['objectDate'] as String? ?? '',
      period:
          _extractPeriod(json['period'] as String? ?? json['objectDate'] as String? ?? ''),
      medium: json['medium'] as String? ?? '',
      dimensions: json['dimensions'] as String?,
      location: json['repository'] as String?,
      imageUrl: primaryImage,
      thumbnailUrl: primaryImageSmall,
      description:
          '${json['title']} is a work by ${json['artistDisplayName'] ?? 'Unknown Artist'}${json['objectDate'] != null ? ", created ${json['objectDate']}" : ""}. ${json['repository'] != null ? "Currently housed at ${json['repository']}." : ""}',
      historicalContext: json['period'] as String?,
      department: json['department'] as String? ?? 'European Paintings',
      isPublicDomain: json['isPublicDomain'] as bool? ?? false,
      keySymbols:
          (json['tags'] as List<dynamic>?)
              ?.map((t) => t['term'] as String)
              .toList() ??
          [],
    );
  }

  static String _extractPeriod(String raw) {
    if (raw.toLowerCase().contains('early')) return 'Early Renaissance';
    if (raw.toLowerCase().contains('high')) return 'High Renaissance';
    if (raw.toLowerCase().contains('northern')) return 'Northern Renaissance';
    if (raw.toLowerCase().contains('flemish')) return 'Flemish';
    if (raw.toLowerCase().contains('manner')) return 'Mannerism';
    if (raw.contains('14')) return 'Early Renaissance';
    if (raw.contains('15')) return 'High Renaissance';
    return 'Renaissance';
  }

  Artwork copyWith({double? aspectRatio}) {
    return Artwork(
      id: id,
      title: title,
      artist: artist,
      year: year,
      period: period,
      medium: medium,
      dimensions: dimensions,
      location: location,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      description: description,
      historicalContext: historicalContext,
      meaning: meaning,
      keySymbols: keySymbols,
      relatedArtworkIds: relatedArtworkIds,
      department: department,
      isPublicDomain: isPublicDomain,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }
}
