import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renaart/models/artwork.dart';
import 'package:renaart/services/met_museum_service.dart';
import 'package:renaart/services/storage_service.dart';

// ── Service providers ──────────────────────────────────────────────────────

final metServiceProvider = Provider<MetMuseumService>((_) => MetMuseumService());

final storageServiceProvider = Provider<StorageService>((_) {
  throw UnimplementedError('Override in main.dart after init');
});

// ── Home Feed ──────────────────────────────────────────────────────────────

final homeFeedProvider = FutureProvider<List<Artwork>>((ref) async {
  final api = ref.read(metServiceProvider);
  final storage = ref.read(storageServiceProvider);

  final ids = await api.getRenaissanceObjectIds();
  if (ids.isEmpty) return [];

  final artworks = await api.getArtworksBatch(ids);
  for (final a in artworks) {
    await storage.cacheArtwork(a);
  }
  return artworks;
});

// ── Artwork Detail ─────────────────────────────────────────────────────────

final artworkDetailProvider =
    FutureProvider.family<Artwork?, String>((ref, id) async {
  final storage = ref.read(storageServiceProvider);
  final cached = storage.getCachedArtwork(id);
  if (cached != null) return cached;

  final api = ref.read(metServiceProvider);
  final artwork = await api.getArtwork(id);
  if (artwork != null) await storage.cacheArtwork(artwork);
  return artwork;
});

// ── Search ─────────────────────────────────────────────────────────────────

class SearchParams {
  final String query;
  final String? artist;
  final String? medium;
  final int? dateBegin;
  final int? dateEnd;

  const SearchParams({
    this.query = '',
    this.artist,
    this.medium,
    this.dateBegin,
    this.dateEnd,
  });

  @override
  bool operator ==(Object other) =>
      other is SearchParams &&
      query == other.query &&
      artist == other.artist &&
      medium == other.medium &&
      dateBegin == other.dateBegin &&
      dateEnd == other.dateEnd;

  @override
  int get hashCode =>
      Object.hash(query, artist, medium, dateBegin, dateEnd);
}

final searchResultsProvider =
    FutureProvider.family<List<Artwork>, SearchParams>((ref, params) async {
  final api = ref.read(metServiceProvider);
  final storage = ref.read(storageServiceProvider);

  final ids = await api.searchArtworks(
    query: params.query,
    artistOrCulture: params.artist,
    medium: params.medium,
    dateBegin: params.dateBegin,
    dateEnd: params.dateEnd,
  );
  if (ids.isEmpty) return [];

  final artworks = await api.getArtworksBatch(ids);
  for (final a in artworks) {
    await storage.cacheArtwork(a);
  }
  return artworks;
});

// ── Favorites ──────────────────────────────────────────────────────────────

class FavoritesNotifier extends Notifier<List<Artwork>> {
  @override
  List<Artwork> build() {
    return ref.read(storageServiceProvider).getFavorites();
  }

  Future<void> toggle(Artwork artwork) async {
    final storage = ref.read(storageServiceProvider);
    await storage.toggleFavorite(artwork);
    state = storage.getFavorites();
  }

  bool isFavorited(String id) {
    return ref.read(storageServiceProvider).isFavorited(id);
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<Artwork>>(FavoritesNotifier.new);

// ── Offline Collection ─────────────────────────────────────────────────────

class OfflineNotifier extends Notifier<List<Artwork>> {
  @override
  List<Artwork> build() {
    return ref.read(storageServiceProvider).getOfflineArtworks();
  }

  Future<bool> saveOffline(Artwork artwork) async {
    final storage = ref.read(storageServiceProvider);
    final ok = await storage.saveOffline(artwork);
    if (ok) state = storage.getOfflineArtworks();
    return ok;
  }

  Future<void> removeOffline(String id) async {
    final storage = ref.read(storageServiceProvider);
    await storage.removeOffline(id);
    state = storage.getOfflineArtworks();
  }

  bool isOfflineSaved(String id) {
    return ref.read(storageServiceProvider).isOfflineSaved(id);
  }

  int get offlineCount => ref.read(storageServiceProvider).offlineCount;
  bool get isFull => ref.read(storageServiceProvider).isOfflineFull;
}

final offlineProvider =
    NotifierProvider<OfflineNotifier, List<Artwork>>(OfflineNotifier.new);
