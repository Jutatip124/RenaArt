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
      if ((data['primaryImage'] as String?)?.isEmpty ?? true) return null;

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
    final limited = ids.take(maxCount * 3).toList(); // over-fetch to account for nulls

    for (final id in limited) {
      if (results.length >= maxCount) break;
      final artwork = await getArtwork(id);
      if (artwork != null) results.add(artwork);
      // Week 3 Security: Client-side rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return results;
  }

  /// Fetch Renaissance artworks for home feed
  /// Uses Met departmentId=11 (European Paintings)
  Future<List<Artwork>> fetchRenaissanceFeed({int count = 20}) async {
    final ids = await searchObjectIds(
      query: AppConstants.renaissanceSearchQuery,
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
    return getArtworkBatch(ids, maxCount: 12);
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
