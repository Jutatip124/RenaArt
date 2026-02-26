class AppConstants {
  static const String appName = 'RenaArt';
  static const String appTagline = 'The Digital Museum of the Renaissance';
  static const int maxOfflineArtworks = 10;
  static const int maxImageResolution = 1080;
  static const String metApiBase =
      'https://collectionapi.metmuseum.org/public/collection/v1';

  // Hive box names
  static const String artworksBox = 'artworks';
  static const String favoritesBox = 'favorites';
  static const String offlineBox = 'offline';
  static const String userBox = 'user';

  // SharedPreferences keys
  static const String themeKey = 'theme_mode';
  static const String guestKey = 'is_guest';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
  static const String nicknameKey = 'nickname';
  static const String emailKey = 'email';
  static const String highFidelityKey = 'high_fidelity';
}

class AppStrings {
  // Bottom Nav
  static const String home = 'Home';
  static const String search = 'Search';
  static const String collection = 'Collection';
  static const String profile = 'Profile';

  // Auth
  static const String signIn = 'Sign In';
  static const String createAccount = 'Create Account';
  static const String continueAsGuest = 'Continue as Guest';
  static const String joinRenaissance = 'Join the Renaissance';

  // Periods
  static const List<String> periods = [
    'All',
    'Early Renaissance',
    'High Renaissance',
    'Northern Renaissance',
    'Mannerism',
    'Flemish',
  ];

  // Artists (for filter)
  static const List<String> popularArtists = [
    'Leonardo da Vinci',
    'Michelangelo',
    'Raphael',
    'Sandro Botticelli',
    'Jan van Eyck',
    'Fra Angelico',
    'Titian',
    'Albrecht Dürer',
  ];

  // Mediums
  static const List<String> mediums = [
    'Painting',
    'Sculpture',
    'Fresco',
    'Drawing',
    'Print',
    'Tapestry',
  ];
}
