import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../models/artwork_model.dart';
import '../../../models/user_model.dart';
import '../../../services/met_api_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/constants/app_constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SERVICES
// ══════════════════════════════════════════════════════════════════════════════
final metApiServiceProvider = Provider<MetApiService>((_) => MetApiService());
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
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) =>
      results.isNotEmpty ? results.first : ConnectivityResult.none);
});

final isOnlineProvider = Provider<bool>((ref) {
  final conn = ref.watch(connectivityProvider).valueOrNull;
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

final homeFeedProvider = FutureProvider.autoDispose<List<Artwork>>((ref) async {
  final api = ref.watch(metApiServiceProvider);
  final storage = ref.watch(storageProvider);
  final isOnline = ref.watch(isOnlineProvider);

  // Week 3 Offline Strategy: Show cached data with offline banner
  if (!isOnline) {
    return storage.getAllCachedArtworks();
  }

  // Fetch from API and cache results
  final artworks = await api.fetchRenaissanceFeed(count: 20);
  if (artworks.isNotEmpty) {
    await storage.cacheArtworks(artworks);
  }

  // Apply period filter (Local State: selectedPeriod)
  final period = ref.watch(selectedPeriodProvider);
  if (period == 'All') return artworks;
  return artworks.where((a) => a.period == period).toList();
});

// ══════════════════════════════════════════════════════════════════════════════
// ARTWORK DETAIL
// ══════════════════════════════════════════════════════════════════════════════
final artworkDetailProvider =
    FutureProvider.family.autoDispose<Artwork?, String>((ref, id) async {
  final storage = ref.watch(storageProvider);
  final api = ref.watch(metApiServiceProvider);

  // Check cache first
  final cached = storage.getCachedArtwork(id);
  if (cached != null) return cached;

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

final searchResultsProvider =
    FutureProvider.autoDispose<List<Artwork>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final artistFilter = ref.watch(searchArtistFilterProvider);
  final periodFilter = ref.watch(searchPeriodFilterProvider);
  final mediumFilter = ref.watch(searchMediumFilterProvider);
  final api = ref.watch(metApiServiceProvider);
  final storage = ref.watch(storageProvider);
  final isOnline = ref.watch(isOnlineProvider);

  if (query.isEmpty && artistFilter == null && periodFilter == null && mediumFilter == null) {
    return storage.getAllCachedArtworks();
  }

  List<Artwork> results;

  if (!isOnline) {
    // Offline: search cache only
    final q = query.toLowerCase();
    results = storage.getAllCachedArtworks().where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.artist.toLowerCase().contains(q) ||
          a.period.toLowerCase().contains(q);
    }).toList();
  } else if (query.isNotEmpty) {
    // Week 3 API Action 1: Search IDs
    results = await api.searchArtworks(query);
    await storage.cacheArtworks(results);
  } else {
    results = storage.getAllCachedArtworks();
  }

  // Apply local filters (Week 3 Local State)
  if (artistFilter != null) {
    results = results.where((a) => a.artist == artistFilter).toList();
  }
  if (periodFilter != null) {
    results = results.where((a) => a.period == periodFilter).toList();
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
