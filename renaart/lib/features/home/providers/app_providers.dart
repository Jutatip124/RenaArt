import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/artwork_model.dart';
import '../../../models/user_model.dart';
import '../../../services/artwork_api_service.dart';
import '../../../services/local_artwork_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/firestore_user_service.dart';
import '../../../core/constants/app_constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SERVICES
// ══════════════════════════════════════════════════════════════════════════════
final storageProvider = Provider<LocalStorageService>(
  (_) => LocalStorageService.instance,
);

final artworkApiServiceProvider = Provider<ArtworkApiService>((ref) {
  return ArtworkApiService(source: AppConstants.activeSource);
});

// ══════════════════════════════════════════════════════════════════════════════
// THEME (Global State — affects all screens)
// ══════════════════════════════════════════════════════════════════════════════
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark) {
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

  final _auth = FirebaseAuth.instance;
  final _db = FirestoreUserService.instance;

  Future<void> _load() async {
    // Try Firebase Auth current user first
    final fbUser = _auth.currentUser;
    if (fbUser != null) {
      final profile = await _db.loadProfile(fbUser.uid, fbUser.email ?? '');
      if (profile != null) {
        await LocalStorageService.instance.saveUser(profile);
        state = profile;
        return;
      }
    }
    // Fall back to locally saved user
    state = await LocalStorageService.instance.loadUser();
  }

  /// Sign in with Firebase Auth. Throws [String] on error.
  Future<void> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final fbUser = cred.user!;
      var profile = await _db.loadProfile(fbUser.uid, email);
      profile ??= UserModel(
        userId: fbUser.uid,
        name: fbUser.displayName ?? email.split('@').first,
        nickname: fbUser.displayName ?? email.split('@').first,
        username: email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_'),
        email: email,
        createdAt: DateTime.now().toIso8601String(),
      );
      await LocalStorageService.instance.saveUser(profile);
      state = profile;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    }
  }

  /// Register with Firebase Auth. Throws [String] on error.
  Future<void> register(String nickname, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final fbUser = cred.user!;
      await fbUser.updateDisplayName(nickname);
      final user = UserModel(
        userId: fbUser.uid,
        name: nickname,
        nickname: nickname,
        username: email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_'),
        email: email,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.saveProfile(user);
      await LocalStorageService.instance.saveUser(user);
      state = user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    }
  }

  /// Send password reset email. Throws [String] on error.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    }
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
    await _db.saveProfile(updated);
    state = updated;
  }

  Future<void> updateUsername(String username) async {
    if (state == null) return;
    final updated = state!.copyWith(username: username);
    await LocalStorageService.instance.saveUser(updated);
    await _db.saveProfile(updated);
    state = updated;
  }

  Future<void> updateEmail(String email) async {
    if (state == null) return;
    try {
      final fbUser = _auth.currentUser;
      if (fbUser != null) {
        await fbUser.verifyBeforeUpdateEmail(email);
      }
      final updated = state!.copyWith(email: email);
      await LocalStorageService.instance.saveUser(updated);
      await _db.saveProfile(updated);
      state = updated;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    }
  }

  Future<void> updatePassword(String password) async {
    if (state == null || password.isEmpty) return;
    try {
      final fbUser = _auth.currentUser;
      if (fbUser != null) {
        await fbUser.updatePassword(password);
      }
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    }
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
    try { await _auth.signOut(); } catch (_) {}
    await LocalStorageService.instance.clearUser();
    state = null;
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again to update this.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication error. Please try again.';
    }
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

  // Try primary data source (Firestore → local asset fallback chain)
  try {
    final api = ref.watch(artworkApiServiceProvider);
    final artworks = await api.fetchRenaissanceFeed(count: 200);
    if (artworks.isNotEmpty) {
      // Cache silently — don't let cache failures break loading
      try { await storage.cacheArtworks(artworks); } catch (_) {}
      return artworks;
    }
  } catch (_) {
    // ArtworkApiService creation or fetch failed — try direct local load
  }

  // Direct local asset fallback (bypasses ArtworkApiService entirely)
  try {
    final local = LocalArtworkService.instance;
    final artworks = await local.fetchRenaissanceFeed(count: 200);
    if (artworks.isNotEmpty) {
      try { await storage.cacheArtworks(artworks); } catch (_) {}
      return artworks;
    }
  } catch (_) {}

  // Last resort: return whatever is in the Hive cache
  try {
    final cached = storage.getAllCachedArtworks();
    if (cached.isNotEmpty) return cached;
  } catch (_) {}

  return [];
});

/// Derived provider — applies period filter locally without triggering API re-fetch
/// Watches [_homeFeedRawProvider] + [selectedPeriodProvider] separately so that
/// changing the period chip only re-filters in memory.
final homeFeedProvider = Provider.autoDispose<AsyncValue<List<Artwork>>>((ref) {
  final feedAsync = ref.watch(_homeFeedRawProvider);
  final period = ref.watch(selectedPeriodProvider);

  return feedAsync.whenData((artworks) {
    // Filter out stale non-Renaissance cache entries (e.g. old AIC data)
    final filtered = artworks.where((a) => a.id.startsWith('local_')).toList();
    if (period == 'All') return filtered;
    return filtered.where((a) => a.period == period).toList();
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
final searchSubjectFilterProvider = StateProvider<String?>((ref) => null);
final searchRegionFilterProvider = StateProvider<String?>((ref) => null);

bool _isFilterableRenaissanceArtwork(Artwork artwork) {
  // Only include curated local artworks (filter out stale AIC/Met/Rijks cache)
  if (!artwork.id.startsWith('local_')) return false;

  final artist = artwork.artist.trim().toLowerCase();
  if (artist.isEmpty || artist == 'unknown artist' || artist == 'anonymous') {
    return false;
  }

  final period = artwork.period.toLowerCase();
  return period.contains('renaissance') ||
      period.contains('mannerism') ||
      period.contains('proto-renaissance');
}

final searchFilterSeedProvider =
    FutureProvider.autoDispose<List<Artwork>>((ref) async {
  final storage = ref.watch(storageProvider);

  var seed = storage.getAllCachedArtworks()
      .where(_isFilterableRenaissanceArtwork)
      .toList();

  if (seed.length < 24) {
    try {
      final api = ref.watch(artworkApiServiceProvider);
      final fetched = await api.fetchRenaissanceFeed(count: 200);
      if (fetched.isNotEmpty) {
        try { await storage.cacheArtworks(fetched); } catch (_) {}
        seed = fetched.where(_isFilterableRenaissanceArtwork).toList();
      }
    } catch (_) {
      // Fallback: try direct local asset load
      try {
        final local = LocalArtworkService.instance;
        final fetched = await local.fetchRenaissanceFeed(count: 200);
        if (fetched.isNotEmpty) {
          seed = fetched.where(_isFilterableRenaissanceArtwork).toList();
        }
      } catch (_) {}
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
  final subjectFilter = ref.watch(searchSubjectFilterProvider);
  final regionFilter = ref.watch(searchRegionFilterProvider);
  final storage = ref.watch(storageProvider);
  final hasAnyFilter = artistFilter != null || periodFilter != null
      || mediumFilter != null || subjectFilter != null || regionFilter != null;

  if (query.isEmpty && !hasAnyFilter) {
    return storage.getAllCachedArtworks()
        .where(_isFilterableRenaissanceArtwork).toList();
  }

  List<Artwork> results;

  // Always use cached data (populated by home feed from local asset)
  results = storage.getAllCachedArtworks();
  if (results.isEmpty) {
    // Fallback: load from API/local directly
    try {
      final api = ref.watch(artworkApiServiceProvider);
      if (query.isNotEmpty) {
        results = await api.searchArtworks(query, maxCount: 300);
      } else {
        results = await api.fetchRenaissanceFeed(count: 300);
      }
      if (results.isNotEmpty) {
        try { await storage.cacheArtworks(results); } catch (_) {}
      }
    } catch (_) {
      // Direct local fallback
      try {
        final local = LocalArtworkService.instance;
        results = query.isNotEmpty
            ? await local.searchArtworks(query, maxCount: 300)
            : await local.fetchRenaissanceFeed(count: 300);
      } catch (_) {}
    }
  }

  results = results.where(_isFilterableRenaissanceArtwork).toList();

  // Apply query text filtering locally
  if (query.isNotEmpty) {
    final q = query.toLowerCase();
    results = results.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.artist.toLowerCase().contains(q) ||
          a.period.toLowerCase().contains(q);
    }).toList();
  }

  // Apply local filters
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
    // type field is stored as 'department' in Artwork model
    results = results.where((a) =>
        a.department.toLowerCase() == mediumFilter.toLowerCase()).toList();
  }
  if (subjectFilter != null) {
    final normalizedSubject = subjectFilter.toLowerCase();
    results = results.where((a) =>
        a.subject.toLowerCase().contains(normalizedSubject)).toList();
  }
  if (regionFilter != null) {
    final normalizedRegion = regionFilter.toLowerCase();
    // origin field is stored as 'location' in Artwork model
    results = results.where((a) =>
        a.location.toLowerCase().contains(normalizedRegion)).toList();
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
