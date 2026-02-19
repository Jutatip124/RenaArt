import 'package:hive/hive.dart';

part 'artwork.g.dart';

@HiveType(typeId: 0)
class Artwork extends HiveObject {
  @HiveField(0)
  final String objectId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artistName;

  @HiveField(3)
  final String? artistBio;

  @HiveField(4)
  final String objectDate;

  @HiveField(5)
  final String? medium;

  @HiveField(6)
  final String? dimensions;

  @HiveField(7)
  final String? department;

  @HiveField(8)
  final String? imageUrl;

  @HiveField(9)
  final String? thumbnailUrl;

  @HiveField(10)
  final String? culture;

  @HiveField(11)
  final String? period;

  @HiveField(12)
  final String? creditLine;

  @HiveField(13)
  final String? accessionYear;

  @HiveField(14)
  final bool isPublicDomain;

  @HiveField(15)
  bool isFavorited;

  @HiveField(16)
  bool isOfflineSaved;

  @HiveField(17)
  DateTime? savedAt;

  Artwork({
    required this.objectId,
    required this.title,
    required this.artistName,
    this.artistBio,
    required this.objectDate,
    this.medium,
    this.dimensions,
    this.department,
    this.imageUrl,
    this.thumbnailUrl,
    this.culture,
    this.period,
    this.creditLine,
    this.accessionYear,
    this.isPublicDomain = true,
    this.isFavorited = false,
    this.isOfflineSaved = false,
    this.savedAt,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      objectId: json['objectID']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      artistName: json['artistDisplayName'] ?? 'Unknown Artist',
      artistBio: json['artistDisplayBio'],
      objectDate: json['objectDate'] ?? '',
      medium: json['medium'],
      dimensions: json['dimensions'],
      department: json['department'],
      imageUrl: json['primaryImage'],
      thumbnailUrl: json['primaryImageSmall'],
      culture: json['culture'],
      period: json['period'],
      creditLine: json['creditLine'],
      accessionYear: json['accessionYear'],
      isPublicDomain: json['isPublicDomain'] ?? false,
    );
  }

  Artwork copyWith({
    bool? isFavorited,
    bool? isOfflineSaved,
    DateTime? savedAt,
  }) {
    return Artwork(
      objectId: objectId,
      title: title,
      artistName: artistName,
      artistBio: artistBio,
      objectDate: objectDate,
      medium: medium,
      dimensions: dimensions,
      department: department,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      culture: culture,
      period: period,
      creditLine: creditLine,
      accessionYear: accessionYear,
      isPublicDomain: isPublicDomain,
      isFavorited: isFavorited ?? this.isFavorited,
      isOfflineSaved: isOfflineSaved ?? this.isOfflineSaved,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
