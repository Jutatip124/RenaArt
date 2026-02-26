import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../models/artwork_model.dart';

/// Week 3 Part 3: The API Bridge — Met Museum REST API
/// Endpoints defined in lab sheet:
///   GET /search?q=...&hasImages=true  → {total, objectIDs}
///   GET /objects/{id}                 → Full artwork JSON
///   (Image download from primaryImage URL)
class MetApiService {
  MetApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.metApiBase,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );
    // Week 3 Security: validate URLs are from Met Museum domain only
    _dio.interceptors.add(_MetApiInterceptor());
  }

  late final Dio _dio;

  /// Week 3 API Action 1: Search IDs
  /// GET /search?q={query}&hasImages=true&departmentId=11
  /// Returns: {total: 142, objectIDs: [11, 12, ...]}
  Future<List<int>> searchObjectIds({
    required String query,
    int? departmentId,
    bool hasImages = true,
  }) async {
    try {
      final params = <String, dynamic>{
        'q': query,
        'hasImages': hasImages,
      };
      if (departmentId != null) params['departmentId'] = departmentId;

      final response = await _dio.get('/search', queryParameters: params);
      final data = response.data as Map<String, dynamic>;

      if (data['total'] == 0) return [];
      return List<int>.from(data['objectIDs'] as List);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Week 3 API Action 2: Get Artwork Detail
  /// GET /objects/{id}
  /// Returns: Full artwork JSON (30+ fields mapped to Artwork model)
  Future<Artwork?> getArtwork(int objectId) async {
    try {
      final response = await _dio.get('/objects/$objectId');
      final data = response.data as Map<String, dynamic>;

      // Week 3: Only use public domain artworks with images
      if (!(data['isPublicDomain'] as bool? ?? false)) return null;
      final primaryImage = (data['primaryImage'] as String?)?.trim() ?? '';
      final primaryImageSmall = (data['primaryImageSmall'] as String?)?.trim() ?? '';
      if (primaryImage.isEmpty && primaryImageSmall.isEmpty) return null;
      if (!_hasNamedArtist(data)) return null;
      if (!_isLikelyRenaissance(data)) return null;

      return Artwork.fromMetApi(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  /// Fetch a batch of artworks by IDs, skip nulls
  /// Week 3: Masonry grid needs multiple artworks at once
  Future<List<Artwork>> getArtworkBatch(
    List<int> ids, {
    int maxCount = 20,
  }) async {
    final results = <Artwork>[];
    final limited = ids.take(maxCount * 3).toList();
    const concurrency = 8;

    for (var i = 0; i < limited.length && results.length < maxCount; i += concurrency) {
      final chunk = limited.skip(i).take(concurrency).toList();
      final chunkResults = await Future.wait(
        chunk.map(getArtwork),
        eagerError: false,
      );

      for (final artwork in chunkResults) {
        if (artwork != null) {
          results.add(artwork);
        }
        if (results.length >= maxCount) break;
      }
    }

    return results;
  }

  /// Fetch Renaissance artworks for home feed
  /// Uses Met departmentId=11 (European Paintings)
  Future<List<Artwork>> fetchRenaissanceFeed({int count = 20}) async {
    final ids = await searchObjectIds(
      query: 'renaissance OR "early renaissance" OR "high renaissance" OR "northern renaissance"',
      departmentId: AppConstants.europeanPaintingsDeptId,
    );
    if (ids.isEmpty) return [];
    ids.shuffle();
    return getArtworkBatch(ids, maxCount: count);
  }

  /// Search artworks by query string
  Future<List<Artwork>> searchArtworks(String query) async {
    final ids = await searchObjectIds(
      query: query,
      departmentId: AppConstants.europeanPaintingsDeptId,
    );
    if (ids.isEmpty) return [];
    return getArtworkBatch(ids, maxCount: 20);
  }

  bool _hasNamedArtist(Map<String, dynamic> data) {
    final artist = (data['artistDisplayName'] as String?)?.trim() ?? '';
    if (artist.isEmpty) return false;

    final normalized = artist.toLowerCase();
    const disallowed = {
      'unknown',
      'unknown artist',
      'anonymous',
      'unidentified artist',
      'unidentified',
    };
    return !disallowed.contains(normalized);
  }

  bool _isLikelyRenaissance(Map<String, dynamic> data) {
    final rawText = [
      data['period'],
      data['objectDate'],
      data['culture'],
      data['title'],
      data['classification'],
      data['objectName'],
      data['artistDisplayName'],
    ].whereType<String>().join(' ').toLowerCase();

    final hasRenaissanceKeywords = rawText.contains('renaissance') ||
        rawText.contains('mannerism') ||
        rawText.contains('flemish') ||
        rawText.contains('quattrocento') ||
        rawText.contains('cinquecento');

    final year = _extractYear((data['objectDate'] as String?) ?? '');
    final inRenaissanceYearRange = year != null && year >= 1400 && year <= 1625;

    return hasRenaissanceKeywords || inRenaissanceYearRange;
  }

  int? _extractYear(String dateText) {
    final matches = RegExp(r'(\d{4})').allMatches(dateText);
    for (final match in matches) {
      final year = int.tryParse(match.group(1)!);
      if (year != null && year > 1000 && year < 2100) {
        return year;
      }
    }
    return null;
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      default:
        return Exception('API error: ${e.message}');
    }
  }
}

/// Week 3 Security: Validate all requests go to Met Museum domain only
class _MetApiInterceptor extends Interceptor {
  static final _validDomain = RegExp(
    r'^https://collectionapi\.metmuseum\.org',
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final fullUrl = options.baseUrl + options.path;
    if (!_validDomain.hasMatch(fullUrl)) {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Blocked: invalid domain $fullUrl',
        ),
      );
      return;
    }
    handler.next(options);
  }
}
