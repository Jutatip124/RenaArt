import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../models/artwork_model.dart';
import '../../../models/user_model.dart';
import '../../../services/met_api_service.dart';
import '../../../services/mock_artwork_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/constants/app_constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SERVICES
// ══════════════════════════════════════════════════════════════════════════════
final metApiServiceProvider = Provider<MetApiService>((_) => MetApiService());
final mockArtworkServiceProvider = Provider<MockArtworkService>(
  (_) => MockArtworkService.instance,
);
final storageProvider = Provider<LocalStorageService>(
  (_) => LocalStorageService.instance,
);

// ══════════════════════════════════════════════════════════════════════════════
// THEME (Global State — affects all screens)
// ══════════════════════════════════════════════════════════════════════════════
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final user = await LocalStorageService.instance.loadUser();
    if (user != null && user.preferences.darkMode) {
      state = ThemeMode.dark;
    }
  }

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    final user = await LocalStorageService.instance.loadUser();
    if (user != null) {
      await LocalStorageService.instance.saveUser(
        user.copyWith(
          preferences: user.preferences.copyWith(darkMode: !isDark),
        ),
      );
    }
  }

  bool get isDark => state == ThemeMode.dark;
}

// ══════════════════════════════════════════════════════════════════════════════
// AUTH (Global State)
// ══════════════════════════════════════════════════════════════════════════════
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    state = await LocalStorageService.instance.loadUser();
  }

  Future<void> signIn(String email, String password) async {
    // Mock auth — replace with real backend when available
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final username = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final user = UserModel(
      userId: userId,
      name: username,
      nickname: username,
      username: username,
      email: email,
      createdAt: DateTime.now().toIso8601String(),
    );
    await LocalStorageService.instance.saveUser(user);
    state = user;
  }

  Future<void> register(String nickname, String email, String password) async {
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final username = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final user = UserModel(
      userId: userId,
      name: nickname,
      nickname: nickname,
      username: username,
      email: email,
      createdAt: DateTime.now().toIso8601String(),
    );
    await LocalStorageService.instance.saveUser(user);
    state = user;
  }

  Future<void> continueAsGuest() async {
    final guest = UserModel.guest();
    await LocalStorageService.instance.saveUser(guest);
    state = guest;
  }

  Future<void> updateNickname(String nickname) async {
    if (state == null) return;
    final updated = state!.copyWith(nickname: nickname);
    await LocalStorageService.instance.saveUser(updated);
    state = updated;
  }

  Future<void> updateUsername(String username) async {
    if (state == null) return;
    final updated = state!.copyWith(username: username);
    await LocalStorageService.instance.saveUser(updated);
    state = updated;
  }

  Future<void> toggleHighFidelity() async {
    if (state == null) return;
    final updated = state!.copyWith(
      preferences: state!.preferences.copyWith(
        highFidelityMode: !state!.preferences.highFidelityMode,
      ),
    );
    await LocalStorageService.instance.saveUser(updated);
    state = updated;
  }

  Future<void> signOut() async {
    await LocalStorageService.instance.clearUser();
    state = null;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONNECTIVITY (Global — Week 3: Offline Strategy)
// ══════════════════════════════════════════════════════════════════════════════
final _connectivityInstance = Provider<Connectivity>((_) => Connectivity());

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  final connectivity = ref.watch(_connectivityInstance);
  return connectivity.onConnectivityChanged.map((results) =>
      results.isNotEmpty ? results.first : ConnectivityResult.none);
});

final isOnlineProvider = Provider<bool>((ref) {
  final connAsync = ref.watch(connectivityProvider);
  // While loading, assume online to avoid false offline banner on startup
  if (connAsync.isLoading) return true;
  final conn = connAsync.valueOrNull;
  return conn != null && conn != ConnectivityResult.none;
});

// ══════════════════════════════════════════════════════════════════════════════
// FAVORITES — Global State (Week 3: needed in Home, Search, Detail, Collection)
// ══════════════════════════════════════════════════════════════════════════════
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier()
      : super(LocalStorageService.instance.getFavoriteIds());

  Future<void> toggle(String artworkId, String userId) async {
    await LocalStorageService.instance.toggleFavorite(artworkId, userId);
    state = LocalStorageService.instance.getFavoriteIds();
  }

  bool isFavorite(String artworkId) => state.contains(artworkId);
}

// ══════════════════════════════════════════════════════════════════════════════
// OFFLINE — Global State (Week 3: check across all screens)
// ══════════════════════════════════════════════════════════════════════════════
final offlineIdsProvider = StateNotifierProvider<OfflineNotifier, List<String>>(
  (ref) => OfflineNotifier(),
);

class OfflineNotifier extends StateNotifier<List<String>> {
  OfflineNotifier()
      : super(LocalStorageService.instance.getOfflineIds());

  bool get isFull => state.length >= AppConstants.maxOfflineArtworks;

  bool isOffline(String artworkId) => state.contains(artworkId);

  /// Returns false if storage full (Week 3 spec)
  bool toggleOffline(Artwork artwork) {
    final ok = LocalStorageService.instance.saveOffline(artwork);
    if (ok) state = LocalStorageService.instance.getOfflineIds();
    return ok;
  }

  void remove(String artworkId) {
    LocalStorageService.instance.removeOffline(artworkId);
    state = LocalStorageService.instance.getOfflineIds();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HOME FEED — Met Museum API + Cache
// ══════════════════════════════════════════════════════════════════════════════
final selectedPeriodProvider = StateProvider<String>((ref) => 'All');

/// Raw fetch provider — only re-runs when connectivity changes, NOT on period change
final _homeFeedRawProvider = FutureProvider.autoDispose<List<Artwork>>((ref) async {
  final mock = ref.watch(mockArtworkServiceProvider);
  final storage = ref.watch(storageProvider);
  final isOnline = ref.watch(isOnlineProvider);

  if (AppConstants.useMockData) {
    final artworks = await mock.fetchRenaissanceFeed(count: 80);
    if (artworks.isNotEmpty) {
      await storage.cacheArtworks(artworks);
    }
    return artworks;
  }

  // Week 3 Offline Strategy: Show cached data with offline banner
  if (!isOnline) {
    return storage.getAllCachedArtworks();
  }

  final api = ref.watch(metApiServiceProvider);

  // Fetch from API and cache results
  final artworks = await api.fetchRenaissanceFeed(count: 20);
  if (artworks.isNotEmpty) {
    await storage.cacheArtworks(artworks);
  }
  return artworks;
});

/// Derived provider — applies period filter locally without triggering API re-fetch
/// Watches [_homeFeedRawProvider] + [selectedPeriodProvider] separately so that
/// changing the period chip only re-filters in memory.
final homeFeedProvider = Provider.autoDispose<AsyncValue<List<Artwork>>>((ref) {
  final feedAsync = ref.watch(_homeFeedRawProvider);
  final period = ref.watch(selectedPeriodProvider);

  return feedAsync.whenData((artworks) {
    if (period == 'All') return artworks;
    return artworks.where((a) => a.period == period).toList();
  });
});

// ══════════════════════════════════════════════════════════════════════════════
// ARTWORK DETAIL
// ══════════════════════════════════════════════════════════════════════════════
final artworkDetailProvider =
    FutureProvider.family.autoDispose<Artwork?, String>((ref, id) async {
  final storage = ref.watch(storageProvider);
  final mock = ref.watch(mockArtworkServiceProvider);

  // Check cache first
  final cached = storage.getCachedArtwork(id);
  if (cached != null) return cached;

  if (AppConstants.useMockData) {
    final artwork = await mock.getArtwork(id);
    if (artwork != null) await storage.cacheArtwork(artwork);
    return artwork;
  }

  final api = ref.watch(metApiServiceProvider);

  // Fetch from API (Week 3 Action 2: GET /objects/{id})
  final artwork = await api.getArtwork(int.tryParse(id) ?? 0);
  if (artwork != null) await storage.cacheArtwork(artwork);
  return artwork;
});

// ══════════════════════════════════════════════════════════════════════════════
// SEARCH — Local State (Week 3: screen-specific)
// ══════════════════════════════════════════════════════════════════════════════
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchArtistFilterProvider = StateProvider<String?>((ref) => null);
final searchPeriodFilterProvider = StateProvider<String?>((ref) => null);
final searchMediumFilterProvider = StateProvider<String?>((ref) => null);

bool _isFilterableRenaissanceArtwork(Artwork artwork) {
  final artist = artwork.artist.trim().toLowerCase();
  if (artist.isEmpty || artist == 'unknown artist' || artist == 'anonymous') {
    return false;
  }

  final period = artwork.period.toLowerCase();
  return period.contains('renaissance') ||
      period.contains('mannerism') ||
      period.contains('flemish');
}

final searchFilterSeedProvider =
    FutureProvider.autoDispose<List<Artwork>>((ref) async {
  final storage = ref.watch(storageProvider);
  final mock = ref.watch(mockArtworkServiceProvider);
  final isOnline = ref.watch(isOnlineProvider);

  if (AppConstants.useMockData) {
    final seed = mock.getAllArtworks().where(_isFilterableRenaissanceArtwork).toList();
    if (seed.isNotEmpty) {
      await storage.cacheArtworks(seed);
    }
    return seed;
  }

  var seed = storage.getAllCachedArtworks()
      .where(_isFilterableRenaissanceArtwork)
      .toList();

  if (isOnline && seed.length < 24) {
    final api = ref.watch(metApiServiceProvider);
    final fetched = await api.fetchRenaissanceFeed(count: 80);
    if (fetched.isNotEmpty) {
      await storage.cacheArtworks(fetched);
      seed = fetched;
    }
  }

  return seed;
});

final availableSearchArtistsProvider = Provider<List<String>>((ref) {
  final seed = ref.watch(searchFilterSeedProvider).valueOrNull;
  if (seed == null || seed.isEmpty) {
    return AppStrings.popularArtists.take(6).toList();
  }

  final counts = <String, int>{};
  for (final artwork in seed) {
    final artist = artwork.artist.trim();
    if (artist.isEmpty || artist.toLowerCase() == 'unknown artist') continue;
    counts[artist] = (counts[artist] ?? 0) + 1;
  }

  final sorted = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return a.key.compareTo(b.key);
    });

  return sorted.take(8).map((e) => e.key).toList();
});

final availableSearchPeriodsProvider = Provider<List<String>>((ref) {
  final seed = ref.watch(searchFilterSeedProvider).valueOrNull;
  final canonical = AppStrings.periods.skip(1).toList();
  if (seed == null || seed.isEmpty) return canonical;

  final set = seed.map((a) => a.period).toSet();
  final filtered = canonical.where(set.contains).toList();
  return filtered.isEmpty ? canonical : filtered;
});

final availableSearchMediumsProvider = Provider<List<String>>((ref) {
  final seed = ref.watch(searchFilterSeedProvider).valueOrNull;
  final canonical = AppStrings.mediums;
  if (seed == null || seed.isEmpty) return canonical;

  final filtered = canonical.where((medium) {
    final m = medium.toLowerCase();
    return seed.any((a) => a.medium.toLowerCase().contains(m));
  }).toList();

  return filtered.isEmpty ? canonical : filtered;
});

final searchResultsProvider =
    FutureProvider.autoDispose<List<Artwork>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  final artistFilter = ref.watch(searchArtistFilterProvider);
  final periodFilter = ref.watch(searchPeriodFilterProvider);
  final mediumFilter = ref.watch(searchMediumFilterProvider);
  final mock = ref.watch(mockArtworkServiceProvider);
  final storage = ref.watch(storageProvider);
  final isOnline = ref.watch(isOnlineProvider);
  final hasAnyFilter =
      artistFilter != null || periodFilter != null || mediumFilter != null;

  if (AppConstants.useMockData) {
    var results = mock.getAllArtworks().where(_isFilterableRenaissanceArtwork).toList();

    if (query.isNotEmpty) {
      final normalizedQuery = query.toLowerCase();
      results = results.where((artwork) {
        return artwork.title.toLowerCase().contains(normalizedQuery) ||
            artwork.artist.toLowerCase().contains(normalizedQuery) ||
            artwork.period.toLowerCase().contains(normalizedQuery) ||
            artwork.medium.toLowerCase().contains(normalizedQuery);
      }).toList();
    }

    if (artistFilter != null) {
      final normalizedArtist = artistFilter.toLowerCase();
      results = results
          .where((artwork) => artwork.artist.toLowerCase().contains(normalizedArtist))
          .toList();
    }

    if (periodFilter != null) {
      final normalizedPeriod = periodFilter.toLowerCase();
      results = results
          .where((artwork) => artwork.period.toLowerCase().contains(normalizedPeriod))
          .toList();
    }

    if (mediumFilter != null) {
      final normalizedMedium = mediumFilter.toLowerCase();
      results = results
          .where((artwork) => artwork.medium.toLowerCase().contains(normalizedMedium))
          .toList();
    }

    if ((query.isNotEmpty || hasAnyFilter) && results.isNotEmpty) {
      await storage.cacheArtworks(results);
    }

    return results;
  }

  if (query.isEmpty && !hasAnyFilter) {
    return storage.getAllCachedArtworks();
  }

  List<Artwork> results;

  if (!isOnline) {
    // Offline: use cache only
    results = storage.getAllCachedArtworks();
  } else if (query.isNotEmpty) {
    final api = ref.watch(metApiServiceProvider);
    // Week 3 API Action 1: Search IDs
    results = await api.searchArtworks(query);
    await storage.cacheArtworks(results);
  } else {
    // Online + filter-only: use cache first, then fetch feed fallback
    results = storage.getAllCachedArtworks();
    if (results.isEmpty) {
      final api = ref.watch(metApiServiceProvider);
      final feed = await api.fetchRenaissanceFeed(count: 60);
      if (feed.isNotEmpty) {
        await storage.cacheArtworks(feed);
        results = feed;
      }
    }
  }

  results = results.where(_isFilterableRenaissanceArtwork).toList();

  // Apply query text filtering locally (works for both online/offline sources)
  if (query.isNotEmpty) {
    final q = query.toLowerCase();
    results = results.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.artist.toLowerCase().contains(q) ||
          a.period.toLowerCase().contains(q);
    }).toList();
  }

  // Apply local filters (Week 3 Local State)
  if (artistFilter != null) {
    final normalizedArtist = artistFilter.toLowerCase();
    results = results
        .where((a) => a.artist.toLowerCase().contains(normalizedArtist))
        .toList();
  }
  if (periodFilter != null) {
    final normalizedPeriod = periodFilter.toLowerCase();
    results = results
        .where((a) => a.period.toLowerCase().contains(normalizedPeriod))
        .toList();
  }
  if (mediumFilter != null) {
    results = results.where((a) =>
        a.medium.toLowerCase().contains(mediumFilter.toLowerCase())).toList();
  }

  return results;
});

// ══════════════════════════════════════════════════════════════════════════════
// COLLECTION (derived from Global State)
// ══════════════════════════════════════════════════════════════════════════════
final favoriteArtworksProvider = Provider<List<Artwork>>((ref) {
  ref.watch(favoritesProvider); // re-eval when favorites change
  return LocalStorageService.instance.getFavorites();
});

final offlineArtworksProvider = Provider<List<Artwork>>((ref) {
  ref.watch(offlineIdsProvider); // re-eval when offline changes
  return LocalStorageService.instance.getOfflineArtworks();
});
