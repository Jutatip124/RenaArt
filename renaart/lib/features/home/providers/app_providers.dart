import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../models/artwork_model.dart';
import '../../../models/user_model.dart';
import '../../../services/aic_api_service.dart';
import '../../../services/artwork_api_service.dart';
import '../../../services/met_api_service.dart';
import '../../../services/mock_artwork_service.dart';
import '../../../services/rijks_api_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/constants/app_constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SERVICES
// ══════════════════════════════════════════════════════════════════════════════
final metApiServiceProvider = Provider<MetApiService>((_) => MetApiService());
final aicApiServiceProvider = Provider<AicApiService>((_) => AicApiService());
final rijksApiServiceProvider =
    Provider<RijksApiService>((_) => RijksApiService());
final mockArtworkServiceProvider = Provider<MockArtworkService>(
  (_) => MockArtworkService.instance,
);
final storageProvider = Provider<LocalStorageService>(
  (_) => LocalStorageService.instance,
);

/// Unified data source — routes to AIC / Rijksmuseum / Met / Mock based on
/// [AppConstants.activeSource] and falls back to mock on any error.
final artworkApiServiceProvider = Provider<ArtworkApiService>((ref) {
  return ArtworkApiService(
    source: AppConstants.activeSource,
    aicService: ref.watch(aicApiServiceProvider),
    rijksService: ref.watch(rijksApiServiceProvider),
    metService: ref.watch(metApiServiceProvider),
    mockService: ref.watch(mockArtworkServiceProvider),
  );
});

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

  Future<void> updateEmail(String email) async {
    if (state == null) return;
    final updated = state!.copyWith(email: email);
    await LocalStorageService.instance.saveUser(updated);
    state = updated;
  }

  Future<void> updatePassword(String password) async {
    // Password stored locally only (mock auth)
    // In production this would call a backend API
    if (state == null || password.isEmpty) return;
    // No-op for now — password not stored in UserModel for security
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
  final storage = ref.watch(storageProvider);
  final api = ref.watch(artworkApiServiceProvider);

  // Load all artworks from local asset and cache for search/filter
  final artworks = await api.fetchRenaissanceFeed(count: 200);
  if (artworks.isNotEmpty) {
    await storage.cacheArtworks(artworks);
  }

  // If local load failed, fallback to cache
  if (artworks.isEmpty) {
    return storage.getAllCachedArtworks();
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

  // Check cache first
  final cached = storage.getCachedArtwork(id);
  if (cached != null) return cached;

  final api = ref.watch(artworkApiServiceProvider);

  // Unified service routes by id prefix (aic_, rijks_, mock_) or active source
  final artwork = await api.getArtwork(id);
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

  var seed = storage.getAllCachedArtworks()
      .where(_isFilterableRenaissanceArtwork)
      .toList();

  if (seed.length < 24) {
    final api = ref.watch(artworkApiServiceProvider);
    final fetched = await api.fetchRenaissanceFeed(count: 200);
    if (fetched.isNotEmpty) {
      await storage.cacheArtworks(fetched);
      seed = fetched.where(_isFilterableRenaissanceArtwork).toList();
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
  const canonical = AppStrings.artForms;
  if (seed == null || seed.isEmpty) return canonical;

  final filtered = canonical.where((artForm) {
    final a = artForm.toLowerCase();
    return seed.any((artwork) => artwork.department.toLowerCase().contains(a));
  }).toList();

  return filtered.isEmpty ? canonical : filtered;
});

final searchResultsProvider =
    FutureProvider.autoDispose<List<Artwork>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  final artistFilter = ref.watch(searchArtistFilterProvider);
  final periodFilter = ref.watch(searchPeriodFilterProvider);
  final mediumFilter = ref.watch(searchMediumFilterProvider);
  final storage = ref.watch(storageProvider);
  final isOnline = ref.watch(isOnlineProvider);
  final hasAnyFilter =
      artistFilter != null || periodFilter != null || mediumFilter != null;

  if (AppConstants.useMockData) {
    // Mock mode uses the unified service (which routes to MockArtworkService internally)
    final api = ref.watch(artworkApiServiceProvider);
    var results = (await api.fetchRenaissanceFeed(count: 80))
        .where(_isFilterableRenaissanceArtwork)
        .toList();

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
          .where((artwork) => artwork.department.toLowerCase().contains(normalizedMedium))
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

  // Always use cached data (populated by home feed from local asset)
  results = storage.getAllCachedArtworks();
  if (results.isEmpty) {
    // Fallback: load from API/local directly
    final api = ref.watch(artworkApiServiceProvider);
    if (query.isNotEmpty) {
      results = await api.searchArtworks(query, maxCount: 200);
    } else {
      results = await api.fetchRenaissanceFeed(count: 200);
    }
    if (results.isNotEmpty) {
      await storage.cacheArtworks(results);
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
        a.department.toLowerCase().contains(mediumFilter.toLowerCase())).toList();
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
