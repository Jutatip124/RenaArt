class UserModel {
  final String userId;
  final String nickname; // Display name, editable freely
  final String username; // ID-like, requires email confirmation to change
  final String email;
  final bool darkMode;
  final bool highFidelityMode;
  final List<String> preferredPeriods;
  final int artworksViewed;
  final bool isGuest;

  const UserModel({
    required this.userId,
    required this.nickname,
    required this.username,
    required this.email,
    this.darkMode = false,
    this.highFidelityMode = true,
    this.preferredPeriods = const ['High Renaissance', 'Early Renaissance'],
    this.artworksViewed = 0,
    this.isGuest = false,
  });

  static UserModel guest() => const UserModel(
    userId: 'guest',
    nickname: 'Guest',
    username: 'guest',
    email: '',
    isGuest: true,
  );

  UserModel copyWith({
    String? nickname,
    String? username,
    String? email,
    bool? darkMode,
    bool? highFidelityMode,
    List<String>? preferredPeriods,
    int? artworksViewed,
  }) {
    return UserModel(
      userId: userId,
      nickname: nickname ?? this.nickname,
      username: username ?? this.username,
      email: email ?? this.email,
      darkMode: darkMode ?? this.darkMode,
      highFidelityMode: highFidelityMode ?? this.highFidelityMode,
      preferredPeriods: preferredPeriods ?? this.preferredPeriods,
      artworksViewed: artworksViewed ?? this.artworksViewed,
      isGuest: isGuest,
    );
  }
}
