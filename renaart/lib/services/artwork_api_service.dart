import '../../core/constants/app_constants.dart';
import '../../models/artwork_model.dart';
import 'firestore_artwork_service.dart';
import 'local_artwork_service.dart';

/// Unified artwork data source.
///
/// Routes to Firestore (primary) or local bundled JSON (fallback).
///
/// Usage (in providers):
///   final service = ref.watch(artworkApiServiceProvider);
///   final feed    = await service.fetchRenaissanceFeed();
class ArtworkApiService {
  ArtworkApiService({
    required this.source,
    LocalArtworkService? localService,
    FirestoreArtworkService? firestoreService,
  })  : _local = localService ?? LocalArtworkService.instance,
        _firestore = firestoreService ?? FirestoreArtworkService.instance;

  final ApiSource source;
  final LocalArtworkService _local;
  final FirestoreArtworkService _firestore;

  // ── Home Feed ─────────────────────────────────────────────────────────────
  Future<List<Artwork>> fetchRenaissanceFeed({int count = 30}) async {
    switch (source) {
      case ApiSource.firestore:
        return _withFallback(
          () => _firestore.fetchRenaissanceFeed(count: count),
          fallback: () => _local.fetchRenaissanceFeed(count: count),
        );
      case ApiSource.localAsset:
        return _local.fetchRenaissanceFeed(count: count);
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<List<Artwork>> searchArtworks(String query,
      {int maxCount = 20}) async {
    switch (source) {
      case ApiSource.firestore:
        return _withFallback(
          () => _firestore.searchArtworks(query, maxCount: maxCount),
          fallback: () => _local.searchArtworks(query, maxCount: maxCount),
        );
      case ApiSource.localAsset:
        return _local.searchArtworks(query, maxCount: maxCount);
    }
  }

  // ── Detail ────────────────────────────────────────────────────────────────
  Future<Artwork?> getArtwork(String id) async {
    switch (source) {
      case ApiSource.firestore:
        final result = await _withFallbackNullable(
          () => _firestore.getArtwork(id),
        );
        return result ?? await _local.getArtwork(id);
      case ApiSource.localAsset:
        return _local.getArtwork(id);
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
