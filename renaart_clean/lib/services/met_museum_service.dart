import 'package:dio/dio.dart';
import 'package:renaart/models/artwork.dart';

class MetMuseumService {
  static const _base = 'https://collectionapi.metmuseum.org/public/collection/v1';

  final Dio _dio;

  MetMuseumService()
      : _dio = Dio(BaseOptions(
          baseUrl: _base,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  /// Returns a list of object IDs matching Renaissance artworks
  Future<List<String>> getRenaissanceObjectIds({String query = ''}) async {
    // Use Met's search endpoint — filter to European Paintings / Drawings & Prints
    // with hasImages=true. For Renaissance, we search by period keywords.
    final queries = query.isEmpty
        ? ['renaissance', 'botticelli', 'raphael', 'michelangelo', 'leonardo']
        : [query];

    final Set<String> ids = {};
    for (final q in queries) {
      try {
        final res = await _dio.get('/search', queryParameters: {
          'q': q,
          'hasImages': true,
          'isPublicDomain': true,
          'medium': 'Paintings',
        });
        final list = (res.data['objectIDs'] as List?)?.cast<int>() ?? [];
        ids.addAll(list.take(20).map((e) => e.toString()));
      } catch (_) {}
    }
    return ids.toList();
  }

  /// Fetch a single artwork by objectID
  Future<Artwork?> getArtwork(String id) async {
    try {
      final res = await _dio.get('/objects/$id');
      final data = res.data as Map<String, dynamic>;

      // Skip items without images
      if ((data['primaryImageSmall'] ?? '').toString().isEmpty) return null;

      return Artwork.fromJson(data);
    } on DioException {
      return null;
    }
  }

  /// Fetch multiple artworks from a list of IDs (parallel)
  Future<List<Artwork>> getArtworksBatch(List<String> ids) async {
    final futures = ids.map(getArtwork).toList();
    final results = await Future.wait(futures);
    return results.whereType<Artwork>().toList();
  }

  /// Search with query text and optional filters
  Future<List<String>> searchArtworks({
    required String query,
    String? artistOrCulture,
    String? medium,
    int? dateBegin,
    int? dateEnd,
  }) async {
    final params = <String, dynamic>{
      'q': query.isEmpty ? 'renaissance' : query,
      'hasImages': true,
      'isPublicDomain': true,
    };
    if (artistOrCulture != null) params['artistOrCulture'] = true;
    if (medium != null) params['medium'] = medium;
    if (dateBegin != null) params['dateBegin'] = dateBegin;
    if (dateEnd != null) params['dateEnd'] = dateEnd;

    try {
      final res = await _dio.get('/search', queryParameters: params);
      final list = (res.data['objectIDs'] as List?)?.cast<int>() ?? [];
      return list.take(30).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }
}
