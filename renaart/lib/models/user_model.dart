/// Week 3 Spec: USER_PROFILE.json entity
/// Stored in SharedPreferences (basic fields) + Hive (computed stats)
class UserModel {
  final String userId; // e.g. "user_6631503124"
  final String name; // Full name
  final String nickname; // Display name — editable freely (Week 1 spec)
  final String username; // ID-like, requires email confirmation to change
  final String email;
  final String? avatarUrl; // Week 3 spec (null = show initials, Week 1 UI spec)
  final String createdAt;
  final UserPreferences preferences;
  final UserStats stats;
  final bool isGuest;

  const UserModel({
    required this.userId,
    required this.name,
    required this.nickname,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.createdAt = '',
    this.preferences = const UserPreferences(),
    this.stats = const UserStats(),
    this.isGuest = false,
  });

  factory UserModel.guest() => const UserModel(
        userId: 'guest',
        name: 'Guest Visitor',
        nickname: 'Guest',
        username: 'guest',
        email: '',
        isGuest: true,
      );

  UserModel copyWith({
    String? userId,
    String? name,
    String? nickname,
    String? username,
    String? email,
    String? avatarUrl,
    String? createdAt,
    UserPreferences? preferences,
    UserStats? stats,
    bool? isGuest,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

/// Week 3: preferences field inside USER_PROFILE.json
class UserPreferences {
  final bool darkMode;
  final bool highFidelityMode;
  final int offlineLimit; // always 10 per spec
  final List<String> preferredPeriods; // ["High Renaissance", "Early Renaissance"]

  const UserPreferences({
    this.darkMode = false,
    this.highFidelityMode = true,
    this.offlineLimit = 10,
    this.preferredPeriods = const ['High Renaissance', 'Early Renaissance'],
  });

  UserPreferences copyWith({bool? darkMode, bool? highFidelityMode}) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      highFidelityMode: highFidelityMode ?? this.highFidelityMode,
      offlineLimit: offlineLimit,
      preferredPeriods: preferredPeriods,
    );
  }
}

/// Week 3: stats field — Calculated from UserArtworkState table / view logs
class UserStats {
  final int totalFavorites; // Calculated from UserArtworkState table
  final int artworksViewed; // Calculated from view logs
  final int totalSaveToReturns; // Week 2: Success metric!
  final int offlineSaved; // Count of offline artworks

  const UserStats({
    this.totalFavorites = 0,
    this.artworksViewed = 0,
    this.totalSaveToReturns = 0,
    this.offlineSaved = 0,
  });

  UserStats copyWith({
    int? totalFavorites,
    int? artworksViewed,
    int? totalSaveToReturns,
    int? offlineSaved,
  }) {
    return UserStats(
      totalFavorites: totalFavorites ?? this.totalFavorites,
      artworksViewed: artworksViewed ?? this.artworksViewed,
      totalSaveToReturns: totalSaveToReturns ?? this.totalSaveToReturns,
      offlineSaved: offlineSaved ?? this.offlineSaved,
    );
  }
}
