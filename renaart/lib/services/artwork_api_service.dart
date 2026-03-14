import '../../core/constants/app_constants.dart';
import '../../models/artwork_model.dart';
import 'aic_api_service.dart';
import 'firestore_artwork_service.dart';
import 'local_artwork_service.dart';
import 'met_api_service.dart';
import 'mock_artwork_service.dart';
import 'rijks_api_service.dart';

/// Unified artwork data source.
///
/// Reads [AppConstants.activeSource] and routes to the correct service.
/// Falls back to mock data if the network request fails.
///
/// Fallback chain:
///   Firestore           → (on error) → LocalAsset
///   ArtInstituteChicago → (on error) → Mock
///   Rijksmuseum         → (on error) → Mock
///   MetMuseum           → (on error) → Mock
///   Mock                → always returns mock data
///
/// Usage (in providers):
///   final service = ref.watch(artworkApiServiceProvider);
///   final feed    = await service.fetchRenaissanceFeed();
class ArtworkApiService {
  ArtworkApiService({
    required this.source,
    required AicApiService aicService,
    required RijksApiService rijksService,
    required MetApiService metService,
    required MockArtworkService mockService,
    LocalArtworkService? localService,
    FirestoreArtworkService? firestoreService,
  })  : _aic = aicService,
        _rijks = rijksService,
        _met = metService,
        _mock = mockService,
        _local = localService ?? LocalArtworkService.instance,
        _firestore = firestoreService ?? FirestoreArtworkService.instance;

  final ApiSource source;
  final AicApiService _aic;
  final RijksApiService _rijks;
  final MetApiService _met;
  final MockArtworkService _mock;
  final LocalArtworkService _local;
  final FirestoreArtworkService _firestore;

  // ── Home Feed ─────────────────────────────────────────────────────────────
  Future<List<Artwork>> fetchRenaissanceFeed({int count = 30}) async {
    switch (source) {      case ApiSource.localAsset:
        return _local.fetchRenaissanceFeed(count: count);      case ApiSource.firestore:
        return _withFallback(
          () => _firestore.fetchRenaissanceFeed(count: count),
          fallback: () => _local.fetchRenaissanceFeed(count: count),
        );      case ApiSource.artInstituteChicago:
        return _withFallback(
          () => _aic.fetchRenaissanceFeed(count: count),
          fallback: () => _mock.fetchRenaissanceFeed(count: count),
        );
      case ApiSource.rijksmuseum:
        return _withFallback(
          () => _rijks.fetchRenaissanceFeed(count: count),
          fallback: () => _mock.fetchRenaissanceFeed(count: count),
        );
      case ApiSource.metMuseum:
        return _withFallback(
          () => _met.fetchRenaissanceFeed(count: count),
          fallback: () => _mock.fetchRenaissanceFeed(count: count),
        );
      case ApiSource.mock:
        return _mock.fetchRenaissanceFeed(count: count);
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<List<Artwork>> searchArtworks(String query,
      {int maxCount = 20}) async {
    switch (source) {      case ApiSource.localAsset:
        return _local.searchArtworks(query, maxCount: maxCount);      case ApiSource.firestore:
        return _withFallback(
          () => _firestore.searchArtworks(query, maxCount: maxCount),
          fallback: () => _local.searchArtworks(query, maxCount: maxCount),
        );      case ApiSource.artInstituteChicago:
        return _withFallback(
          () => _aic.searchArtworks(query, maxCount: maxCount),
          fallback: () => _mock.searchArtworks(query, maxCount: maxCount),
        );
      case ApiSource.rijksmuseum:
        return _withFallback(
          () => _rijks.searchArtworks(query, maxCount: maxCount),
          fallback: () => _mock.searchArtworks(query, maxCount: maxCount),
        );
      case ApiSource.metMuseum:
        return _withFallback(
          () => _met.searchArtworks(query),
          fallback: () => _mock.searchArtworks(query, maxCount: maxCount),
        );
      case ApiSource.mock:
        return _mock.searchArtworks(query, maxCount: maxCount);
    }
  }

  // ── Detail ────────────────────────────────────────────────────────────────
  Future<Artwork?> getArtwork(String id) async {
    // Route based on ID prefix (supports mixed cache from multiple sources)
    if (id.startsWith('local_')) {
      // Try Firestore first if active, fall back to local
      if (source == ApiSource.firestore) {
        final result = await _withFallbackNullable(() => _firestore.getArtwork(id));
        if (result != null) return result;
      }
      return _local.getArtwork(id);
    }
    if (id.startsWith('aic_')) {
      return _withFallbackNullable(() => _aic.getArtwork(id));
    }
    if (id.startsWith('rijks_')) {
      return _withFallbackNullable(() => _rijks.getArtwork(id));
    }
    if (id.startsWith('mock_')) {
      return _mock.getArtwork(id);
    }
    // Legacy Met Museum numeric ID or active-source fallback
    switch (source) {
      case ApiSource.localAsset:
        return _local.getArtwork(id);
      case ApiSource.firestore:
        return _withFallbackNullable(() => _firestore.getArtwork(id));
      case ApiSource.artInstituteChicago:
        return _withFallbackNullable(() => _aic.getArtwork(id));
      case ApiSource.rijksmuseum:
        return _withFallbackNullable(() => _rijks.getArtwork(id));
      case ApiSource.metMuseum:
        return _withFallbackNullable(
            () => _met.getArtwork(int.tryParse(id) ?? 0));
      case ApiSource.mock:
        return _mock.getArtwork(id);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<List<Artwork>> _withFallback(
    Future<List<Artwork>> Function() primary, {
    required Future<List<Artwork>> Function() fallback,
  }) async {
    try {
      final result = await primary();
      if (result.isNotEmpty) return result;
      return fallback();
    } catch (_) {
      return fallback();
    }
  }

  Future<Artwork?> _withFallbackNullable(
      Future<Artwork?> Function() primary) async {
    try {
      return await primary();
    } catch (_) {
      return null;
    }
  }
}
