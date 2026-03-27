import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../models/artwork_model.dart';
import '../../models/user_model.dart';
import 'secure_storage_service.dart';

/// Week 3 Part 3: Local Storage
/// - Favorites: Room.insert(UserArtworkState)  →  Hive box
/// - Offline:   FileSystem + Room               →  Hive box (MAX 10)
/// - User:      SharedPreferences/Room          →  SharedPreferences
///
/// Week 5 Spec: "Do not use any BuildContext. This is a pure service class."
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  Box<Artwork>? _artworksCache;
  Box<UserArtworkState>? _favoritesBox;
  Box<OfflineArtwork>? _offlineBox;

  bool get _ready =>
      _artworksCache != null && _favoritesBox != null && _offlineBox != null;

  /// Initialize Hive boxes — call in main() before runApp
  Future<void> init() async {
    try {
      await Hive.initFlutter();
    } catch (_) {
      // Hive web init can fail if IndexedDB is blocked or corrupted
      return;
    }

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ArtworkAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserArtworkStateAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(OfflineArtworkAdapter());

    // Open boxes — clear corrupted data on error and retry
    _artworksCache = await _openBoxSafe<Artwork>(AppConstants.artworksBoxName);
    _favoritesBox = await _openBoxSafe<UserArtworkState>(AppConstants.favoritesBoxName);
    _offlineBox = await _openBoxSafe<OfflineArtwork>(AppConstants.offlineBoxName);
  }

  Future<Box<T>> _openBoxSafe<T>(String name) async {
    try {
      return await Hive.openBox<T>(name);
    } catch (_) {
      await Hive.deleteBoxFromDisk(name);
      return await Hive.openBox<T>(name);
    }
  }

  // ─── Artworks Cache ─────────────────────────────────────────────────────────

  Future<void> cacheArtwork(Artwork artwork) async {
    await _artworksCache?.put(artwork.id, artwork);
  }

  Future<void> cacheArtworks(List<Artwork> artworks) async {
    if (_artworksCache == null) return;
    final map = {for (final a in artworks) a.id: a};
    await _artworksCache!.putAll(map);
  }

  Artwork? getCachedArtwork(String id) => _artworksCache?.get(id);

  List<Artwork> getAllCachedArtworks() =>
      _artworksCache?.values.toList() ?? [];

  // ─── Favorites (Week 3: Room.insert(UserArtworkState)) ───────────────────

  /// Toggle favorite — uses composite key `userId_artworkId` for per-user scoping
  Future<void> toggleFavorite(String artworkId, String userId) async {
    if (_favoritesBox == null) return;
    final key = '${userId}_$artworkId';
    final existing = _favoritesBox!.get(key);
    if (existing != null && existing.isFavorited) {
      await _favoritesBox!.delete(key);
    } else {
      await _favoritesBox!.put(
        key,
        UserArtworkState(
          artworkId: artworkId,
          userId: userId,
          isFavorited: true,
          favoritedDate: DateTime.now().toIso8601String(),
          viewCount: existing?.viewCount ?? 0,
        ),
      );
    }
  }

  bool isFavorite(String artworkId, String userId) {
    final key = '${userId}_$artworkId';
    final state = _favoritesBox?.get(key);
    return state?.isFavorited ?? false;
  }

  /// Week 5 Spec: getFavorites(): return List by querying artworks box with favorites keys
  List<Artwork> getFavorites(String userId) {
    if (!_ready) return [];
    final favoriteIds = _favoritesBox!.values
        .where((s) => s.isFavorited && s.userId == userId)
        .map((s) => s.artworkId)
        .toSet();
    return _artworksCache!.values
        .where((a) => favoriteIds.contains(a.id))
        .toList();
  }

  List<String> getFavoriteIds(String userId) {
    if (_favoritesBox == null) return [];
    return _favoritesBox!.values
        .where((s) => s.isFavorited && s.userId == userId)
        .map((s) => s.artworkId)
        .toList();
  }

  // ─── Offline Storage (Week 3: MAX 10 artworks) ────────────────────────────

  /// Week 5 Spec: isOfflineFull getter: returns bool when offline.length >= 10
  bool get isOfflineFull =>
      (_offlineBox?.length ?? 0) >= AppConstants.maxOfflineArtworks;

  int get offlineCount => _offlineBox?.length ?? 0;

  bool isOffline(String artworkId) =>
      _offlineBox?.containsKey(artworkId) ?? false;

  /// Week 5 Spec: saveOffline(Artwork): save to offline box with MAX 10 limit, return bool
  /// Returns false if full (Week 3: "Storage Full (10/10)" scenario)
  bool saveOffline(Artwork artwork) {
    if (_offlineBox == null) return false;
    if (isOffline(artwork.id)) {
      _offlineBox!.delete(artwork.id);
      return true;
    }
    if (isOfflineFull) return false;

    _offlineBox!.put(
      artwork.id,
      OfflineArtwork(
        artworkId: artwork.id,
        isOfflineAvailable: true,
        downloadedDate: DateTime.now().toIso8601String(),
        imageResolution: '1080x1440',
        lastAccessDate: DateTime.now().toIso8601String(),
      ),
    );
    return true;
  }

  void removeOffline(String artworkId) {
    _offlineBox?.delete(artworkId);
  }

  /// Week 5 Spec: getOfflineArtworks(): same pattern as getFavorites
  List<Artwork> getOfflineArtworks() {
    if (!_ready) return [];
    final offlineIds = _offlineBox!.keys.cast<String>().toSet();
    return _artworksCache!.values
        .where((a) => offlineIds.contains(a.id))
        .toList();
  }

  List<String> getOfflineIds() =>
      _offlineBox?.keys.cast<String>().toList() ?? [];

  // ─── View Tracking (Week 3: viewCount in UserArtworkState) ───────────────

  Future<void> recordView(String artworkId, String userId) async {
    if (_favoritesBox == null) return;
    final key = '${userId}_$artworkId';
    final existing = _favoritesBox!.get(key);
    if (existing != null) {
      existing.viewCount = (existing.viewCount) + 1;
      existing.lastViewed = DateTime.now().toIso8601String();
      await existing.save();
    } else {
      await _favoritesBox!.put(
        key,
        UserArtworkState(
          artworkId: artworkId,
          userId: userId,
          isFavorited: false,
          lastViewed: DateTime.now().toIso8601String(),
          viewCount: 1,
        ),
      );
    }
  }

  int getViewCount(String artworkId, String userId) =>
      _favoritesBox?.get('${userId}_$artworkId')?.viewCount ?? 0;

  // ─── User Profile (SharedPreferences) ────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Store PII in secure storage (encrypted)
    await SecureStorageService.instance.saveSecureUserData(
      userId: user.userId,
      email: user.email,
      username: user.username,
    );
    
    // Store non-sensitive preferences in SharedPreferences
    await prefs.setString(AppConstants.keyUserId, user.userId);
    await prefs.setString(AppConstants.keyNickname, user.nickname);
    await prefs.setBool(AppConstants.keyIsGuest, user.isGuest);
    await prefs.setBool(AppConstants.keyThemeMode, user.preferences.darkMode);
    await prefs.setBool(AppConstants.keyHighFidelity, user.preferences.highFidelityMode);
  }

  Future<UserModel?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.keyUserId);
    if (userId == null) return null;

    final isGuest = prefs.getBool(AppConstants.keyIsGuest) ?? false;
    if (isGuest) return UserModel.guest();

    // Load PII from secure storage
    final secureData = await SecureStorageService.instance.loadSecureUserData();
    final email = secureData?['email'] ?? '';
    final username = secureData?['username'] ?? 'user';

    return UserModel(
      userId: userId,
      name: prefs.getString(AppConstants.keyNickname) ?? '',
      nickname: prefs.getString(AppConstants.keyNickname) ?? 'Art Lover',
      username: username,
      email: email,
      preferences: UserPreferences(
        darkMode: prefs.getBool(AppConstants.keyThemeMode) ?? false,
        highFidelityMode: prefs.getBool(AppConstants.keyHighFidelity) ?? true,
      ),
      stats: UserStats(
        totalFavorites: getFavoriteIds(userId).length,
        offlineSaved: offlineCount,
      ),
    );
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // DON'T clear favorites - they should persist across login/logout
    // Favorites are keyed by userId, so each user sees only their own
    // await _favoritesBox?.clear();  // REMOVED
    
    // DON'T clear offline artworks either - they're useful for returning users
    // await _offlineBox?.clear();  // REMOVED
    
    // Clear secure storage (PII only)
    await SecureStorageService.instance.clearSecureData();
  }
}
