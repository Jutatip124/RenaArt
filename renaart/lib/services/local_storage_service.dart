import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../models/artwork_model.dart';
import '../../models/user_model.dart';

/// Week 3 Part 3: Local Storage
/// - Favorites: Room.insert(UserArtworkState)  →  Hive box
/// - Offline:   FileSystem + Room               →  Hive box (MAX 10)
/// - User:      SharedPreferences/Room          →  SharedPreferences
///
/// Week 5 Spec: "Do not use any BuildContext. This is a pure service class."
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  late Box<Artwork> _artworksCache;
  late Box<UserArtworkState> _favoritesBox;
  late Box<OfflineArtwork> _offlineBox;

  /// Initialize Hive boxes — call in main() before runApp
  Future<void> init() async {
    await Hive.initFlutter();

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
    await _artworksCache.put(artwork.id, artwork);
  }

  Future<void> cacheArtworks(List<Artwork> artworks) async {
    final map = {for (final a in artworks) a.id: a};
    await _artworksCache.putAll(map);
  }

  Artwork? getCachedArtwork(String id) => _artworksCache.get(id);

  List<Artwork> getAllCachedArtworks() => _artworksCache.values.toList();

  // ─── Favorites (Week 3: Room.insert(UserArtworkState)) ───────────────────

  /// Week 5 Spec: toggleFavorite(Artwork): add/remove from favorites box
  Future<void> toggleFavorite(String artworkId, String userId) async {
    final existing = _favoritesBox.get(artworkId);
    if (existing != null && existing.isFavorited) {
      // Remove
      await _favoritesBox.delete(artworkId);
    } else {
      // Add
      await _favoritesBox.put(
        artworkId,
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

  bool isFavorite(String artworkId) {
    final state = _favoritesBox.get(artworkId);
    return state?.isFavorited ?? false;
  }

  /// Week 5 Spec: getFavorites(): return List by querying artworks box with favorites keys
  List<Artwork> getFavorites() {
    final favoriteIds = _favoritesBox.values
        .where((s) => s.isFavorited)
        .map((s) => s.artworkId)
        .toSet();
    return _artworksCache.values
        .where((a) => favoriteIds.contains(a.id))
        .toList();
  }

  List<String> getFavoriteIds() {
    return _favoritesBox.values
        .where((s) => s.isFavorited)
        .map((s) => s.artworkId)
        .toList();
  }

  // ─── Offline Storage (Week 3: MAX 10 artworks) ────────────────────────────

  /// Week 5 Spec: isOfflineFull getter: returns bool when offline.length >= 10
  bool get isOfflineFull =>
      _offlineBox.length >= AppConstants.maxOfflineArtworks;

  int get offlineCount => _offlineBox.length;

  bool isOffline(String artworkId) => _offlineBox.containsKey(artworkId);

  /// Week 5 Spec: saveOffline(Artwork): save to offline box with MAX 10 limit, return bool
  /// Returns false if full (Week 3: "Storage Full (10/10)" scenario)
  bool saveOffline(Artwork artwork) {
    if (isOffline(artwork.id)) {
      // Toggle off
      _offlineBox.delete(artwork.id);
      return true;
    }
    if (isOfflineFull) return false; // Week 3: return false if full

    _offlineBox.put(
      artwork.id,
      OfflineArtwork(
        artworkId: artwork.id,
        isOfflineAvailable: true,
        downloadedDate: DateTime.now().toIso8601String(),
        imageResolution: '1080x1440', // Week 3: capped at 1080p
        lastAccessDate: DateTime.now().toIso8601String(),
      ),
    );
    return true;
  }

  void removeOffline(String artworkId) {
    _offlineBox.delete(artworkId);
  }

  /// Week 5 Spec: getOfflineArtworks(): same pattern as getFavorites
  List<Artwork> getOfflineArtworks() {
    final offlineIds = _offlineBox.keys.cast<String>().toSet();
    return _artworksCache.values
        .where((a) => offlineIds.contains(a.id))
        .toList();
  }

  List<String> getOfflineIds() => _offlineBox.keys.cast<String>().toList();

  // ─── View Tracking (Week 3: viewCount in UserArtworkState) ───────────────

  Future<void> recordView(String artworkId, String userId) async {
    final existing = _favoritesBox.get(artworkId);
    if (existing != null) {
      existing.viewCount = (existing.viewCount) + 1;
      existing.lastViewed = DateTime.now().toIso8601String();
      await existing.save();
    } else {
      await _favoritesBox.put(
        artworkId,
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

  int getViewCount(String artworkId) =>
      _favoritesBox.get(artworkId)?.viewCount ?? 0;

  // ─── User Profile (SharedPreferences) ────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserId, user.userId);
    await prefs.setString(AppConstants.keyNickname, user.nickname);
    await prefs.setString(AppConstants.keyUsername, user.username);
    await prefs.setString(AppConstants.keyEmail, user.email);
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

    return UserModel(
      userId: userId,
      name: prefs.getString(AppConstants.keyNickname) ?? '',
      nickname: prefs.getString(AppConstants.keyNickname) ?? 'Art Lover',
      username: prefs.getString(AppConstants.keyUsername) ?? 'user',
      email: prefs.getString(AppConstants.keyEmail) ?? '',
      preferences: UserPreferences(
        darkMode: prefs.getBool(AppConstants.keyThemeMode) ?? false,
        highFidelityMode: prefs.getBool(AppConstants.keyHighFidelity) ?? true,
      ),
      stats: UserStats(
        totalFavorites: getFavoriteIds().length,
        offlineSaved: offlineCount,
      ),
    );
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
