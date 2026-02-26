import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/artwork_model.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../../models/mock_data.dart';

// ─── THEME PROVIDER ───────────────────────────────────────────────────────────
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(AppConstants.themeKey) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final newMode =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.themeKey, newMode == ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}

// ─── AUTH PROVIDER ─────────────────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.userIdKey);
    if (userId != null) {
      final isGuest = prefs.getBool(AppConstants.guestKey) ?? false;
      if (isGuest) {
        state = UserModel.guest();
      } else {
        state = UserModel(
          userId: userId,
          nickname: prefs.getString(AppConstants.nicknameKey) ?? 'Art Lover',
          username: prefs.getString(AppConstants.usernameKey) ?? 'user',
          email: prefs.getString(AppConstants.emailKey) ?? '',
          darkMode: prefs.getBool(AppConstants.themeKey) ?? false,
          highFidelityMode:
              prefs.getBool(AppConstants.highFidelityKey) ?? true,
        );
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    // Mock sign in
    final prefs = await SharedPreferences.getInstance();
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final username = email.split('@').first.replaceAll('.', '_');
    await prefs.setString(AppConstants.userIdKey, userId);
    await prefs.setString(AppConstants.emailKey, email);
    await prefs.setString(AppConstants.usernameKey, username);
    await prefs.setString(AppConstants.nicknameKey, username);
    await prefs.setBool(AppConstants.guestKey, false);
    state = UserModel(
      userId: userId,
      nickname: username,
      username: username,
      email: email,
    );
  }

  Future<void> register(
      String nickname, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final username = email.split('@').first.replaceAll('.', '_');
    await prefs.setString(AppConstants.userIdKey, userId);
    await prefs.setString(AppConstants.emailKey, email);
    await prefs.setString(AppConstants.usernameKey, username);
    await prefs.setString(AppConstants.nicknameKey, nickname);
    await prefs.setBool(AppConstants.guestKey, false);
    state = UserModel(
      userId: userId,
      nickname: nickname,
      username: username,
      email: email,
    );
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userIdKey, 'guest');
    await prefs.setBool(AppConstants.guestKey, true);
    state = UserModel.guest();
  }

  Future<void> updateNickname(String nickname) async {
    if (state == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.nicknameKey, nickname);
    state = state!.copyWith(nickname: nickname);
  }

  Future<void> updateUsername(String username) async {
    if (state == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.usernameKey, username);
    state = state!.copyWith(username: username);
  }

  Future<void> toggleHighFidelity() async {
    if (state == null) return;
    final prefs = await SharedPreferences.getInstance();
    final newVal = !state!.highFidelityMode;
    await prefs.setBool(AppConstants.highFidelityKey, newVal);
    state = state!.copyWith(highFidelityMode: newVal);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = null;
  }
}

// ─── FAVORITES PROVIDER ────────────────────────────────────────────────────────
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]);

  void toggle(String artworkId) {
    if (state.contains(artworkId)) {
      state = state.where((id) => id != artworkId).toList();
    } else {
      state = [...state, artworkId];
    }
  }

  bool isFavorite(String artworkId) => state.contains(artworkId);
}

// ─── OFFLINE PROVIDER ──────────────────────────────────────────────────────────
final offlineProvider =
    StateNotifierProvider<OfflineNotifier, List<String>>(
  (ref) => OfflineNotifier(),
);

class OfflineNotifier extends StateNotifier<List<String>> {
  OfflineNotifier() : super([]);

  bool get isFull => state.length >= AppConstants.maxOfflineArtworks;

  bool isOffline(String artworkId) => state.contains(artworkId);

  /// Returns false if storage is full
  bool saveOffline(String artworkId) {
    if (state.contains(artworkId)) {
      state = state.where((id) => id != artworkId).toList();
      return true;
    }
    if (isFull) return false;
    state = [...state, artworkId];
    return true;
  }

  void remove(String artworkId) {
    state = state.where((id) => id != artworkId).toList();
  }
}

// ─── ARTWORKS FEED PROVIDER ────────────────────────────────────────────────────
final selectedPeriodProvider = StateProvider<String>((ref) => 'All');

final homeFeedProvider = Provider<List<Artwork>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  return MockData.getByPeriod(period);
});

// ─── SEARCH PROVIDER ───────────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchArtistFilterProvider = StateProvider<String?>((ref) => null);
final searchPeriodFilterProvider = StateProvider<String?>((ref) => null);
final searchMediumFilterProvider = StateProvider<String?>((ref) => null);

final searchResultsProvider = Provider<List<Artwork>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final artist = ref.watch(searchArtistFilterProvider);
  final period = ref.watch(searchPeriodFilterProvider);
  final medium = ref.watch(searchMediumFilterProvider);

  var results = MockData.artworks;

  if (query.isNotEmpty) {
    results = MockData.search(query);
  }
  if (artist != null) {
    results = results.where((a) => a.artist == artist).toList();
  }
  if (period != null) {
    results = results.where((a) => a.period == period).toList();
  }
  if (medium != null) {
    results = results
        .where(
          (a) => a.medium.toLowerCase().contains(medium.toLowerCase()),
        )
        .toList();
  }
  return results;
});

// ─── COLLECTION PROVIDER ───────────────────────────────────────────────────────
final favoriteArtworksProvider = Provider<List<Artwork>>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  return MockData.artworks
      .where((a) => favoriteIds.contains(a.id))
      .toList();
});

final offlineArtworksProvider = Provider<List<Artwork>>((ref) {
  final offlineIds = ref.watch(offlineProvider);
  return MockData.artworks.where((a) => offlineIds.contains(a.id)).toList();
});
