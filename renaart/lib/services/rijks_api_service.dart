import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../models/artwork_model.dart';

/// Rijksmuseum Collection API
/// Docs: https://data.rijksmuseum.nl/object-metadata/api/
///
/// Key advantage:
///   ✅ Single search request returns full objects + image URLs
///   ✅ Dutch & Flemish Renaissance focus (van Eyck, Bruegel, Bosch)
///   ✅ Very fast Google CDN images (resizable via =s{pixels})
///   ✅ Free API key (register at https://www.rijksmuseum.nl/nl/rijksstudio)
///   ⚠️  Requires API key: set via --dart-define=RIJKS_API_KEY=xxx
///       or replace AppConstants.rijksApiKey directly for local dev
class RijksApiService {
  RijksApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  late final Dio _dio;

  // ── Home Feed ─────────────────────────────────────────────────────────────
  /// Fetch Dutch/Flemish Renaissance artworks for home feed.
  Future<List<Artwork>> fetchRenaissanceFeed({int count = 30}) async {
    try {
      final response = await _dio.get(
        AppConstants.rijksApiBase,
        queryParameters: {
          'key': AppConstants.rijksApiKey,
          'q': 'renaissance',
          'type': 'painting',
          'imgonly': true,
          'toppieces': false,
          'ps': count,           // page size
          'p': 1,                // page number
          'f.dating.period': 16, // 16th century (1500s)
        },
      );
      return _parseResults(response.data);
    } on DioException catch (_) {
      // Fallback without period filter
      return _search('renaissance OR flemish OR bosch OR bruegel', count: count);
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<List<Artwork>> searchArtworks(String query,
      {int maxCount = 20}) async {
    return _search(query, count: maxCount);
  }

  // ── Detail (by Rijksmuseum object number) ─────────────────────────────────
  Future<Artwork?> getArtwork(String rijksId) async {
    try {
      final objectNumber = rijksId.replaceFirst('rijks_', '');
      final response = await _dio.get(
        '${AppConstants.rijksApiBase}/$objectNumber',
        queryParameters: {'key': AppConstants.rijksApiKey},
      );
      final data = response.data['artObject'] as Map<String, dynamic>?;
      if (data == null) return null;
      return Artwork.fromRijksApi(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      return null;
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────────
  Future<List<Artwork>> _search(String query, {int count = 20}) async {
    try {
      final response = await _dio.get(
        AppConstants.rijksApiBase,
        queryParameters: {
          'key': AppConstants.rijksApiKey,
          'q': query,
          'imgonly': true,
          'ps': count,
          'p': 1,
        },
      );
      return _parseResults(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  List<Artwork> _parseResults(dynamic responseData) {
    final list = responseData['artObjects'] as List<dynamic>? ?? [];
    final artworks = <Artwork>[];
    for (final item in list) {
      try {
        final map = item as Map<String, dynamic>;
        final webImage = map['webImage'] as Map<String, dynamic>?;
        if (webImage == null || (webImage['url'] as String? ?? '').isEmpty) {
          continue;
        }
        artworks.add(Artwork.fromRijksApi(map));
      } catch (_) {
        continue;
      }
    }
    return artworks;
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Rijksmuseum API timed out.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      default:
        return Exception('Rijksmuseum API error: ${e.message}');
    }
  }
}
