import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/artwork_model.dart';
import '../../../models/user_model.dart';
import '../../../services/artwork_api_service.dart';
import '../../../services/local_artwork_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/firestore_user_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../firebase_options.dart';

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
  (ref) => ThemeNotifier(ref),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  ThemeNotifier(this._ref) : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    try {
      final user = await LocalStorageService.instance.loadUser();
      if (user != null) {
        state = user.preferences.darkMode ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      debugPrint('ThemeNotifier._load failed: $e');
    }
  }

  void syncFromUser(UserModel? user) {
    if (user != null) {
      state = user.preferences.darkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    final user = await LocalStorageService.instance.loadUser();
    if (user != null) {
      final updated = user.copyWith(
        preferences: user.preferences.copyWith(darkMode: !isDark),
      );
      await LocalStorageService.instance.saveUser(updated);
      // Sync to Firestore — fire-and-forget, never retry on quota error
      try {
        await FirestoreUserService.instance.saveProfile(updated);
      } catch (e) {
        debugPrint('ThemeNotifier.toggle sync failed: $e');
      }
      _ref.read(authProvider.notifier).refreshState(updated);
    }
  }

  bool get isDark => state == ThemeMode.dark;
}

// ══════════════════════════════════════════════════════════════════════════════
// AUTH (Global State)
// ══════════════════════════════════════════════════════════════════════════════
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier(ref),
);

/// Whether auth has finished its initial load
final authLoadedProvider = StateProvider<bool>((ref) => false);

class AuthNotifier extends StateNotifier<UserModel?> {
  final Ref _ref;

  // ── Quota guard ───────────────────────────────────────────────────────────
  // Set to true when Firestore returns quota-exceeded. All subsequent writes
  // are skipped for the lifetime of this notifier (i.e. until page reload).
  bool _firestoreQuotaExceeded = false;

  AuthNotifier(this._ref) : super(null) {
    _load();
  }

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint('AuthNotifier._auth failed: $e');
      return null;
    }
  }

  final _db = FirestoreUserService.instance;

  /// Ensure Firebase is initialized before auth operations.
  Future<bool> _ensureFirebaseReady() async {
    if (Firebase.apps.isNotEmpty) return true;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return true;
    } catch (e) {
      debugPrint('AuthNotifier._ensureFirebaseReady failed: $e');
      return false;
    }
  }

  // ── Firestore helpers ─────────────────────────────────────────────────────

  /// Returns true if the exception looks like a quota / resource error.
  bool _isQuotaError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('quota') ||
        msg.contains('resource-exhausted') ||
        msg.contains('insufficient');
  }

  /// Load profile from Firestore with quota guard.
  Future<UserModel?> _safeLoadProfile(String uid, String email) async {
    if (_firestoreQuotaExceeded) return null;
    try {
      return await _db.loadProfile(uid, email);
    } catch (e) {
      if (_isQuotaError(e)) _firestoreQuotaExceeded = true;
      return null;
    }
  }

  /// Save profile to Firestore with quota guard — fire-and-forget.
  Future<void> _safeSaveProfile(UserModel profile) async {
    if (_firestoreQuotaExceeded) return;
    try {
      await _db.saveProfile(profile);
    } catch (e) {
      if (_isQuotaError(e)) _firestoreQuotaExceeded = true;
    }
  }

  /// Claim username with quota guard — fire-and-forget.
  Future<void> _safeClaimUsername(String username, String uid) async {
    if (_firestoreQuotaExceeded) return;
    try {
      await _db.claimUsername(username, uid);
    } catch (e) {
      if (_isQuotaError(e)) _firestoreQuotaExceeded = true;
    }
  }

  // ── Internal load ─────────────────────────────────────────────────────────

  /// Load auth state from Firebase, then reconcile with local cache.
  Future<void> _load() async {
    try {
      final firebaseReady = await _ensureFirebaseReady();
      if (!firebaseReady) {
        debugPrint(
            'AuthNotifier._load: Firebase not ready, loading local user');
        state = await LocalStorageService.instance.loadUser();
        _syncThemeAndMarkLoaded();
        return;
      }

      final auth = _auth;
      if (auth == null) {
        debugPrint('AuthNotifier._load: auth is null, loading local user');
        state = await LocalStorageService.instance.loadUser();
        _syncThemeAndMarkLoaded();
        return;
      }

      // ✅ วิธีที่ถูกต้อง: รอ authStateChanges emit ครั้งแรก
      // ไม่ใช้ currentUser โดยตรง เพราะบน Web มันยัง null อยู่ระหว่างโหลด IndexedDB
      debugPrint('AuthNotifier._load: Waiting for authStateChanges...');
      final fbUser = await auth
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('AuthNotifier._load: Timeout waiting for auth state');
        return null;
      });

      if (fbUser != null) {
        debugPrint('AuthNotifier._load: Firebase user found: ${fbUser.email}');
        await _handleFirebaseUser(fbUser);
        _syncThemeAndMarkLoaded();
        return;
      }

      debugPrint('AuthNotifier._load: No Firebase user, loading local user');
      final localUser = await LocalStorageService.instance.loadUser();
      if (localUser != null && !localUser.isGuest) {
        // Local session can be stale when Firebase auth on web has expired/cleared.
        // Clear stale local auth snapshot to avoid unauthorized Firestore reads.
        debugPrint('AuthNotifier._load: Clearing stale local user session');
        await LocalStorageService.instance.clearUser();
        state = null;
      } else {
        state = localUser;
      }
    } catch (e) {
      debugPrint('AuthNotifier._load failed: $e');
      try {
        final localUser = await LocalStorageService.instance.loadUser();
        if (localUser != null && !localUser.isGuest) {
          await LocalStorageService.instance.clearUser();
          state = null;
        } else {
          state = localUser;
        }
      } catch (e2) {
        debugPrint('AuthNotifier._load local fallback failed: $e2');
        state = null;
      }
    }
    _syncThemeAndMarkLoaded();
  }

  void _syncThemeAndMarkLoaded() {
    _ref.read(themeModeProvider.notifier).syncFromUser(state);
    _ref.read(authLoadedProvider.notifier).state = true;
  }

  void refreshState(UserModel updated) => state = updated;

  /// Shared helper: load or create profile from a Firebase user.
  Future<void> _handleFirebaseUser(User fbUser) async {
    final email = fbUser.email ?? '';
    final generatedUsername = email.isNotEmpty
        ? email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        : 'user_${fbUser.uid.substring(0, 8)}';

    // ALWAYS try Firestore first for source of truth
    UserModel? profile = await _safeLoadProfile(fbUser.uid, email);

    if (profile != null) {
      // Firestore profile exists - use it as source of truth
      // Only update if fields are empty
      bool needsUpdate = false;

      if (profile.email.isEmpty && email.isNotEmpty) {
        profile = profile.copyWith(email: email);
        needsUpdate = true;
      }
      if (profile.nickname.isEmpty &&
          (fbUser.displayName?.isNotEmpty ?? false)) {
        profile = profile.copyWith(nickname: fbUser.displayName);
        needsUpdate = true;
      }
      if (profile.createdAt.isEmpty) {
        profile = profile.copyWith(createdAt: DateTime.now().toIso8601String());
        needsUpdate = true;
      }
      // Don't overwrite username if it's already set and not 'user'
      if (profile.username == 'user' && generatedUsername != 'user') {
        profile = profile.copyWith(username: generatedUsername);
        needsUpdate = true;
      }

      if (needsUpdate) {
        await _safeSaveProfile(profile);
      }
      await LocalStorageService.instance.saveUser(profile);
      state = profile;
      return;
    }

    // No Firestore profile - check local cache
    final UserModel? local = await LocalStorageService.instance.loadUser();
    if (local != null && !local.isGuest && local.userId == fbUser.uid) {
      // Local profile exists but not in Firestore - save to Firestore
      await _safeSaveProfile(local);
      state = local;
      return;
    }

    // Create new profile
    final newProfile = UserModel(
      userId: fbUser.uid,
      name: fbUser.displayName ?? generatedUsername,
      nickname: fbUser.displayName ?? generatedUsername,
      username: generatedUsername,
      email: email,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _safeSaveProfile(newProfile);
    await _safeClaimUsername(generatedUsername, fbUser.uid);
    await LocalStorageService.instance.saveUser(newProfile);
    state = newProfile;
  }

  // ── Public auth actions ───────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    final firebaseReady = await _ensureFirebaseReady();
    if (!firebaseReady) throw 'Service unavailable. Please try again later.';

    final auth = _auth;
    if (auth == null) throw 'Service unavailable. Please try again later.';
    try {
      final cred = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      final fbUser = cred.user;
      if (fbUser == null) throw 'Email or password is incorrect.';

      var profile = await _safeLoadProfile(fbUser.uid, email);
      profile ??= UserModel(
        userId: fbUser.uid,
        name: fbUser.displayName ?? email.split('@').first,
        nickname: fbUser.displayName ?? email.split('@').first,
        username:
            email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_'),
        email: email,
        createdAt: DateTime.now().toIso8601String(),
      );
      await LocalStorageService.instance.saveUser(profile);
      state = profile;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Email or password is incorrect.';
    }
  }

  Future<void> signInWithGoogle() async {
    final firebaseReady = await _ensureFirebaseReady();
    if (!firebaseReady) throw 'Service unavailable. Please try again later.';

    final auth = _auth;
    if (auth == null) throw 'Service unavailable. Please try again later.';
    try {
      final provider = GoogleAuthProvider();
      final result = await auth.signInWithPopup(provider);
      final fbUser = result.user;
      if (fbUser == null) throw 'Google sign-in failed.';
      await _handleFirebaseUser(fbUser);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Google sign-in failed. Please try again.';
    }
  }

  Future<void> register(
      String nickname, String username, String email, String password) async {
    final firebaseReady = await _ensureFirebaseReady();
    if (!firebaseReady) throw 'Service unavailable. Please try again later.';

    final auth = _auth;
    if (auth == null) throw 'Service unavailable. Please try again later.';
    try {
      if (!_firestoreQuotaExceeded) {
        final available = await _db.isUsernameAvailable(username);
        if (!available) throw 'Username "@$username" is already taken.';
      }

      final cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final fbUser = cred.user;
      if (fbUser == null) throw 'Registration failed. Please try again.';
      await fbUser.updateDisplayName(nickname);
      final user = UserModel(
        userId: fbUser.uid,
        name: nickname,
        nickname: nickname,
        username: username,
        email: email,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _safeClaimUsername(username, fbUser.uid);
      await _safeSaveProfile(user);
      await LocalStorageService.instance.saveUser(user);
      state = user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Registration failed. Please try again.';
    }
  }

  Future<bool> isUsernameAvailable(String username) {
    if (_firestoreQuotaExceeded) return Future.value(true);
    return _db.isUsernameAvailable(username);
  }

  Future<void> reauthenticate(String password) async {
    final fbUser = _auth?.currentUser;
    if (fbUser == null || fbUser.email == null) {
      throw 'No authenticated user found. Please sign in again.';
    }
    try {
      final cred = EmailAuthProvider.credential(
          email: fbUser.email!, password: password);
      await fbUser.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Authentication failed. Please try again.';
    }
  }

  Future<void> resetPassword(String email) async {
    final firebaseReady = await _ensureFirebaseReady();
    if (!firebaseReady) throw 'Service unavailable. Please try again later.';

    final auth = _auth;
    if (auth == null) throw 'Service unavailable. Please try again later.';
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Could not send reset email. Please try again.';
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
    await _safeSaveProfile(updated);
    state = updated;
  }

  Future<void> updateUsername(String newUsername) async {
    if (state == null) return;
    if (!_firestoreQuotaExceeded) {
      final available = await _db.isUsernameAvailable(newUsername);
      if (!available) throw 'Username "@$newUsername" is already taken.';
    }
    final oldUsername = state!.username;
    await _safeClaimUsername(newUsername, state!.userId);
    if (!_firestoreQuotaExceeded) {
      try {
        await _db.releaseUsername(oldUsername);
      } catch (e) {
        debugPrint('AuthNotifier.updateUsername releaseUsername failed: $e');
      }
    }
    final updated = state!.copyWith(username: newUsername);
    await LocalStorageService.instance.saveUser(updated);
    await _safeSaveProfile(updated);
    state = updated;
  }

  Future<void> updateEmail(String email) async {
    if (state == null) return;
    try {
      final fbUser = _auth?.currentUser;
      if (fbUser != null) {
        await fbUser.verifyBeforeUpdateEmail(email);
      }
      final updated = state!.copyWith(email: email);
      await LocalStorageService.instance.saveUser(updated);
      await _safeSaveProfile(updated);
      state = updated;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Could not update email. Please try again.';
    }
  }

  Future<void> updatePassword(String password) async {
    if (state == null || password.isEmpty) return;
    try {
      final fbUser = _auth?.currentUser;
      if (fbUser != null) await fbUser.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Could not update password. Please try again.';
    }
  }

  /// Submit a problem report — silently ignored when quota exceeded.
  Future<void> submitReport(String category, String description) async {
    if (_firestoreQuotaExceeded) return;
    final userId = state?.userId ?? 'anonymous';
    try {
      await _db.submitReport(userId, category, description);
    } catch (e) {
      if (_isQuotaError(e)) _firestoreQuotaExceeded = true;
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
    await _safeSaveProfile(updated);
    state = updated;
  }

  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (e) {
      debugPrint('AuthNotifier.signOut failed: $e');
    }
    await LocalStorageService.instance.clearUser();
    state = null;
  }

  Future<void> deleteAccount(String password) async {
    final auth = _auth;
    final fbUser = auth?.currentUser;
    if (fbUser == null) throw 'No authenticated user found.';
    try {
      if (fbUser.email != null) {
        final cred = EmailAuthProvider.credential(
            email: fbUser.email!, password: password);
        await fbUser.reauthenticateWithCredential(cred);
      }
      if (!_firestoreQuotaExceeded) {
        final username = state?.username;
        if (username != null) {
          try {
            await _db.releaseUsername(username);
          } catch (e) {
            debugPrint('deleteAccount releaseUsername failed: $e');
          }
        }
        try {
          await _db.deleteAllFavorites(fbUser.uid);
        } catch (e) {
          debugPrint('deleteAccount deleteAllFavorites failed: $e');
        }
        try {
          await _db.deleteProfile(fbUser.uid);
        } catch (e) {
          debugPrint('deleteAccount deleteProfile failed: $e');
        }
        try {
          await _db.deleteUserReports(fbUser.uid);
        } catch (e) {
          debugPrint('Failed to delete user reports: $e');
        }
      }
      await fbUser.delete();
      await LocalStorageService.instance.clearUser();
      state = null;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    } catch (e) {
      if (e is String) rethrow;
      throw 'Could not delete account. Please try again.';
    }
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
      case 'invalid-api-key':
        return 'App configuration error. Please refresh the page.';
      case 'app-not-authorized':
        return 'App not authorized. Please contact support.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
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
  if (connAsync.isLoading) return true;
  final conn = connAsync.valueOrNull;
  return conn != null && conn != ConnectivityResult.none;
});

// ══════════════════════════════════════════════════════════════════════════════
// FAVORITES — Global State with Firestore Sync
// ══════════════════════════════════════════════════════════════════════════════
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>(
  (ref) {
    final userId = ref.watch(authProvider)?.userId ?? 'guest';
    return FavoritesNotifier(userId, ref);
  },
);

class FavoritesNotifier extends StateNotifier<List<String>> {
  final String _userId;
  bool _cloudSynced = false;

  FavoritesNotifier(this._userId, Ref ref)
      : super(LocalStorageService.instance.getFavoriteIds(_userId)) {
    // Load favorites from cloud on init (for logged-in users)
    _syncFromCloud();
  }

  /// Sync favorites from Firestore to local storage
  Future<void> _syncFromCloud() async {
    if (_userId == 'guest' || _cloudSynced) return;
    String? authUid;
    try {
      authUid = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      authUid = null;
    }
    if (authUid == null || authUid != _userId) return;

    try {
      final cloudFavorites =
          await FirestoreUserService.instance.loadFavorites(_userId);
      if (cloudFavorites.isNotEmpty) {
        // Merge cloud favorites with local
        for (final artworkId in cloudFavorites) {
          await LocalStorageService.instance
              .addFavoriteLocally(artworkId, _userId);
        }
        // Update state
        state = LocalStorageService.instance.getFavoriteIds(_userId);
      }
      _cloudSynced = true;
    } catch (e) {
      debugPrint('FavoritesNotifier._syncFromCloud failed: $e');
    }
  }

  Future<void> toggle(String artworkId) async {
    // Toggle locally first (instant UI feedback)
    final isNowFavorited =
        await LocalStorageService.instance.toggleFavorite(artworkId, _userId);
    state = LocalStorageService.instance.getFavoriteIds(_userId);

    // Sync to cloud (fire and forget for responsiveness)
    if (_userId != 'guest') {
      String? authUid;
      try {
        authUid = FirebaseAuth.instance.currentUser?.uid;
      } catch (_) {
        authUid = null;
      }
      if (authUid != _userId) return;

      if (isNowFavorited) {
        FirestoreUserService.instance.addFavorite(_userId, artworkId);
      } else {
        FirestoreUserService.instance.removeFavorite(_userId, artworkId);
      }
    }
  }

  bool isFavorite(String artworkId) => state.contains(artworkId);

  /// Force refresh from cloud
  Future<void> refreshFromCloud() async {
    _cloudSynced = false;
    await _syncFromCloud();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OFFLINE — Global State
// ══════════════════════════════════════════════════════════════════════════════
final offlineIdsProvider = StateNotifierProvider<OfflineNotifier, List<String>>(
  (ref) => OfflineNotifier(),
);

class OfflineNotifier extends StateNotifier<List<String>> {
  OfflineNotifier() : super(LocalStorageService.instance.getOfflineIds());

  bool get isFull => state.length >= AppConstants.maxOfflineArtworks;
  bool isOffline(String artworkId) => state.contains(artworkId);

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
// HOME FEED — Local Asset + Cache (Firestore reads removed)
// ══════════════════════════════════════════════════════════════════════════════
final selectedPeriodProvider = StateProvider<String>((ref) => 'For You');

final _homeFeedRawProvider =
    FutureProvider.autoDispose<List<Artwork>>((ref) async {
  final storage = ref.watch(storageProvider);

  // ── 1. Return Hive cache immediately if populated ──────────────────────────
  final cached = storage.getAllCachedArtworks();
  if (cached.isNotEmpty) return cached;

  // ── 2. Load from local asset bundle (no network / Firestore calls) ─────────
  try {
    final local = LocalArtworkService.instance;
    final artworks = await local.fetchRenaissanceFeed(count: 200);
    if (artworks.isNotEmpty) {
      try {
        await storage.cacheArtworks(artworks);
      } catch (e) {
        debugPrint('homeFeed cache failed: $e');
      }
      return artworks;
    }
  } catch (e) {
    debugPrint('homeFeed local load failed: $e');
  }

  // ── 3. Try ArtworkApiService as last resort ────────────────────────────────
  try {
    final api = ref.watch(artworkApiServiceProvider);
    final artworks = await api.fetchRenaissanceFeed(count: 200);
    if (artworks.isNotEmpty) {
      try {
        await storage.cacheArtworks(artworks);
      } catch (e) {
        debugPrint('homeFeed api cache failed: $e');
      }
      return artworks;
    }
  } catch (e) {
    debugPrint('homeFeed api load failed: $e');
  }

  return [];
});

final homeFeedProvider = Provider.autoDispose<AsyncValue<List<Artwork>>>((ref) {
  final feedAsync = ref.watch(_homeFeedRawProvider);
  final period = ref.watch(selectedPeriodProvider);

  return feedAsync.whenData((artworks) {
    final filtered = artworks.where((a) => a.id.startsWith('local_')).toList();
    List<Artwork> result;
    if (period == 'For You') {
      result = filtered;
    } else if (period.contains('Renaissance') || period == 'Mannerism') {
      result = filtered.where((a) => a.period == period).toList();
    } else {
      final subjectMatch = filtered.where((a) => a.subject == period).toList();
      if (subjectMatch.isNotEmpty) {
        result = subjectMatch;
      } else {
        final lp = period.toLowerCase();
        result = filtered.where((a) {
          final m = a.medium.toLowerCase();
          if (lp == 'painting') {
            return m.contains('oil') ||
                m.contains('tempera') ||
                m.contains('panel') ||
                m.contains('canvas');
          }
          if (lp == 'sculpture') {
            return m.contains('marble') ||
                m.contains('bronze') ||
                m.contains('sculpture');
          }
          if (lp == 'fresco') return m.contains('fresco');
          return false;
        }).toList();
      }
    }
    result.shuffle();
    return result;
  });
});

// ══════════════════════════════════════════════════════════════════════════════
// ARTWORK DETAIL
// ══════════════════════════════════════════════════════════════════════════════
final artworkDetailProvider =
    FutureProvider.family.autoDispose<Artwork?, String>((ref, id) async {
  final storage = ref.watch(storageProvider);
  final cached = storage.getCachedArtwork(id);
  if (cached != null) return cached;

  final api = ref.watch(artworkApiServiceProvider);
  final artwork = await api.getArtwork(id);
  if (artwork != null) await storage.cacheArtwork(artwork);
  return artwork;
});

// ══════════════════════════════════════════════════════════════════════════════
// SEARCH — Local State
// ══════════════════════════════════════════════════════════════════════════════
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchArtistFilterProvider = StateProvider<String?>((ref) => null);
final searchPeriodFilterProvider = StateProvider<String?>((ref) => null);
final searchMediumFilterProvider = StateProvider<String?>((ref) => null);
final searchSubjectFilterProvider = StateProvider<String?>((ref) => null);
final searchRegionFilterProvider = StateProvider<String?>((ref) => null);

bool _isFilterableRenaissanceArtwork(Artwork artwork) {
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

  var seed = storage
      .getAllCachedArtworks()
      .where(_isFilterableRenaissanceArtwork)
      .toList();

  if (seed.length < 24) {
    try {
      final local = LocalArtworkService.instance;
      final fetched = await local.fetchRenaissanceFeed(count: 200);
      if (fetched.isNotEmpty) {
        try {
          await storage.cacheArtworks(fetched);
        } catch (e) {
          debugPrint('searchFilterSeed cache failed: $e');
        }
        seed = fetched.where(_isFilterableRenaissanceArtwork).toList();
      }
    } catch (e) {
      debugPrint('searchFilterSeed local load failed: $e');
      try {
        final api = ref.watch(artworkApiServiceProvider);
        final fetched = await api.fetchRenaissanceFeed(count: 200);
        if (fetched.isNotEmpty) {
          try {
            await storage.cacheArtworks(fetched);
          } catch (e2) {
            debugPrint('searchFilterSeed api cache failed: $e2');
          }
          seed = fetched.where(_isFilterableRenaissanceArtwork).toList();
        }
      } catch (e2) {
        debugPrint('searchFilterSeed api load failed: $e2');
      }
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
  final hasAnyFilter = artistFilter != null ||
      periodFilter != null ||
      mediumFilter != null ||
      subjectFilter != null ||
      regionFilter != null;

  if (query.isEmpty && !hasAnyFilter) {
    return storage
        .getAllCachedArtworks()
        .where(_isFilterableRenaissanceArtwork)
        .toList();
  }

  List<Artwork> results = storage.getAllCachedArtworks();

  if (results.isEmpty) {
    try {
      final local = LocalArtworkService.instance;
      results = query.isNotEmpty
          ? await local.searchArtworks(query, maxCount: 300)
          : await local.fetchRenaissanceFeed(count: 300);
      if (results.isNotEmpty) {
        try {
          await storage.cacheArtworks(results);
        } catch (e) {
          debugPrint('searchResults cache failed: $e');
        }
      }
    } catch (e) {
      debugPrint('searchResults local load failed: $e');
      try {
        final api = ref.watch(artworkApiServiceProvider);
        results = query.isNotEmpty
            ? await api.searchArtworks(query, maxCount: 300)
            : await api.fetchRenaissanceFeed(count: 300);
        if (results.isNotEmpty) {
          try {
            await storage.cacheArtworks(results);
          } catch (e2) {
            debugPrint('searchResults api cache failed: $e2');
          }
        }
      } catch (e2) {
        debugPrint('searchResults api load failed: $e2');
      }
    }
  }

  results = results.where(_isFilterableRenaissanceArtwork).toList();

  if (query.isNotEmpty) {
    final q = query.toLowerCase();
    results = results
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.artist.toLowerCase().contains(q) ||
            a.period.toLowerCase().contains(q))
        .toList();
  }

  if (artistFilter != null) {
    final n = artistFilter.toLowerCase();
    results = results.where((a) => a.artist.toLowerCase().contains(n)).toList();
  }
  if (periodFilter != null) {
    final n = periodFilter.toLowerCase();
    results = results.where((a) => a.period.toLowerCase().contains(n)).toList();
  }
  if (mediumFilter != null) {
    results = results
        .where((a) => a.department.toLowerCase() == mediumFilter.toLowerCase())
        .toList();
  }
  if (subjectFilter != null) {
    final n = subjectFilter.toLowerCase();
    results =
        results.where((a) => a.subject.toLowerCase().contains(n)).toList();
  }
  if (regionFilter != null) {
    final n = regionFilter.toLowerCase();
    results =
        results.where((a) => a.location.toLowerCase().contains(n)).toList();
  }

  results.shuffle();
  return results;
});

// ══════════════════════════════════════════════════════════════════════════════
// COLLECTION (derived from Global State)
// ══════════════════════════════════════════════════════════════════════════════
final favoriteArtworksProvider = Provider<List<Artwork>>((ref) {
  ref.watch(favoritesProvider);
  final userId = ref.watch(authProvider)?.userId ?? 'guest';
  return LocalStorageService.instance.getFavorites(userId);
});

final offlineArtworksProvider = Provider<List<Artwork>>((ref) {
  ref.watch(offlineIdsProvider);
  return LocalStorageService.instance.getOfflineArtworks();
});
