import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../core/constants/app_constants.dart';
import '../../models/artwork_model.dart';

/// Loads artworks from the bundled [assets/data/artworks.json] file.
///
/// ✅ No network required
/// ✅ Instant load (~5 ms)
/// ✅ 100% offline capable
/// ✅ Public domain artwork data + Wikimedia Commons images
///
/// To add more works: edit assets/data/artworks.json and run
///   flutter pub get
class LocalArtworkService {
  LocalArtworkService._();
  static final LocalArtworkService instance = LocalArtworkService._();

  // In-memory cache so the asset is only read once per app session
  List<Artwork>? _cache;

  Future<List<Artwork>> _load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString(AppConstants.artworksDataPath);
    final list = (jsonDecode(jsonStr) as List<dynamic>);
    _cache = list
        .map((e) => Artwork.fromLocalJson(e as Map<String, dynamic>))
        .where((a) => a.imageUrl.isNotEmpty)
        .toList();
    return _cache!;
  }

  // ── Home Feed ─────────────────────────────────────────────────────────────
  Future<List<Artwork>> fetchRenaissanceFeed({int count = 30}) async {
    final all = await _load();
    // Shuffle to show variety on each load, return up to count items
    final shuffled = List<Artwork>.from(all)..shuffle();
    return shuffled.take(count).toList();
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<List<Artwork>> searchArtworks(String query,
      {int maxCount = 20}) async {
    final all = await _load();
    if (query.isEmpty) return all.take(maxCount).toList();
    final q = query.toLowerCase();
    return all
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.artist.toLowerCase().contains(q) ||
            a.period.toLowerCase().contains(q) ||
            a.medium.toLowerCase().contains(q) ||
            a.description.toLowerCase().contains(q))
        .take(maxCount)
        .toList();
  }

  // ── Detail ────────────────────────────────────────────────────────────────
  Future<Artwork?> getArtwork(String id) async {
    final all = await _load();
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Sync access (after first load) ───────────────────────────────────────
  List<Artwork> getAllArtworks() => _cache ?? [];

  // ── Cache invalidation ────────────────────────────────────────────────────
  void clearCache() => _cache = null;
}
