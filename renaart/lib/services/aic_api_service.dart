import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../models/artwork_model.dart';

/// Art Institute of Chicago Open API
/// Docs: https://api.artic.edu/docs/
///
/// Key advantage over Met API:
///   ✅ Single request returns FULL objects (title, artist, image_id, etc.)
///   ✅ No two-step ID-batch pattern
///   ✅ Fast IIIF image CDN (Cloudfront backed)
///   ✅ No API key required
///   ✅ 60 req/min rate limit (generous)
///
/// Renaissance filter strategy:
///   - date_start between 1300–1600
///   - style_title contains "Renaissance" / "Flemish" / "Mannerism"
///   - is_public_domain = true
class AicApiService {
  AicApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.aicApiBase,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Accept': 'application/json',
          // Identify our app per AIC best practices
          'AIC-User-Agent': 'RenaArt/1.0 (contact@renaart.app)',
        },
      ),
    );
  }

  late final Dio _dio;

  static const _fieldsParam =
      'id,title,artist_display,artist_id,date_display,date_start,date_end,'
      'medium_display,dimensions,image_id,thumbnail,'
      'artwork_type_title,classification_title,'
      'place_of_origin,is_public_domain,department_title,'
      'style_title,subject_titles';

  // ── Home Feed ─────────────────────────────────────────────────────────────
  /// Fetch Renaissance artworks for home feed.
  /// Single request — returns [count] full objects immediately.
  Future<List<Artwork>> fetchRenaissanceFeed({int count = 30}) async {
    try {
      // Strategy: search by date range + require images + public domain
      final response = await _dio.get(
        '/artworks/search',
        queryParameters: {
          'q': 'renaissance',
          'fields': _fieldsParam,
          'limit': count,
          'boost': false,
          'query': {
            'bool': {
              'must': [
                {'term': {'is_public_domain': true}},
                {'exists': {'field': 'image_id'}},
              ],
              'filter': [
                {
                  'range': {
                    'date_start': {'gte': 1300, 'lte': 1600},
                  }
                }
              ],
            }
          },
        },
      );

      return _parseResults(response.data);
    } on DioException catch (_) {
      // Fallback: simpler keyword search
      return _fallbackSearch('renaissance painting sculpture 1300 1600', count: count);
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  /// Search artworks by keyword — returns full objects in one request.
  Future<List<Artwork>> searchArtworks(String query,
      {int maxCount = 20}) async {
    return _fallbackSearch(query, count: maxCount);
  }

  // ── Detail ────────────────────────────────────────────────────────────────
  /// Get a single artwork by its AIC id (strip 'aic_' prefix first).
  Future<Artwork?> getArtwork(String aicId) async {
    try {
      final numericId = aicId.replaceFirst('aic_', '');
      final response = await _dio.get(
        '/artworks/$numericId',
        queryParameters: {'fields': _fieldsParam},
      );
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      if (data['image_id'] == null) return null;
      if (data['is_public_domain'] != true) return null;
      return Artwork.fromAicApi(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      return null;
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────────
  Future<List<Artwork>> _fallbackSearch(String query,
      {int count = 20}) async {
    try {
      final response = await _dio.get(
        '/artworks/search',
        queryParameters: {
          'q': query,
          'fields': _fieldsParam,
          'limit': count,
        },
      );
      return _parseResults(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  List<Artwork> _parseResults(dynamic responseData) {
    final list = responseData['data'] as List<dynamic>? ?? [];
    final artworks = <Artwork>[];
    for (final item in list) {
      try {
        final map = item as Map<String, dynamic>;
        if (map['image_id'] == null) continue;
        if (map['is_public_domain'] != true) continue;
        final artwork = Artwork.fromAicApi(map);
        if (artwork.imageUrl.isEmpty) continue;
        artworks.add(artwork);
      } catch (_) {
        continue; // skip malformed entries
      }
    }
    return artworks;
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('AIC API timed out.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      default:
        return Exception('AIC API error: ${e.message}');
    }
  }
}
