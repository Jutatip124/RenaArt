import 'package:hive_flutter/hive_flutter.dart';
import 'package:renaart/models/artwork.dart';

class StorageService {
  static const _artworkBox = 'artworks';
  static const _favBox = 'favorites';
  static const _offlineBox = 'offline';
  static const maxOfflineArtworks = 10;

  late Box<Artwork> _artworks;
  late Box<String> _favorites;
  late Box<String> _offline;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ArtworkAdapter());
    _artworks = await Hive.openBox<Artwork>(_artworkBox);
    _favorites = await Hive.openBox<String>(_favBox);
    _offline = await Hive.openBox<String>(_offlineBox);
  }

  // ── Cache artwork data ──────────────────────────────────────
  Future<void> cacheArtwork(Artwork artwork) async {
    await _artworks.put(artwork.objectId, artwork);
  }

  Artwork? getCachedArtwork(String id) => _artworks.get(id);

  // ── Favorites ──────────────────────────────────────────────
  bool isFavorited(String id) => _favorites.containsKey(id);

  Future<void> toggleFavorite(Artwork artwork) async {
    if (_favorites.containsKey(artwork.objectId)) {
      await _favorites.delete(artwork.objectId);
    } else {
      await _favorites.put(artwork.objectId, artwork.objectId);
      await cacheArtwork(artwork);
    }
  }

  List<Artwork> getFavorites() {
    return _favorites.keys
        .map((k) => _artworks.get(k))
        .whereType<Artwork>()
        .toList();
  }

  // ── Offline Saving ─────────────────────────────────────────
  bool isOfflineSaved(String id) => _offline.containsKey(id);

  int get offlineCount => _offline.length;

  bool get isOfflineFull => _offline.length >= maxOfflineArtworks;

  Future<bool> saveOffline(Artwork artwork) async {
    if (_offline.containsKey(artwork.objectId)) return true; // already saved
    if (_offline.length >= maxOfflineArtworks) return false; // full

    await _offline.put(artwork.objectId, artwork.objectId);
    await cacheArtwork(artwork);
    return true;
  }

  Future<void> removeOffline(String id) async {
    await _offline.delete(id);
  }

  List<Artwork> getOfflineArtworks() {
    return _offline.keys
        .map((k) => _artworks.get(k))
        .whereType<Artwork>()
        .toList();
  }
}
