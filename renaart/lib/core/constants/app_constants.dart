// App-wide constants, string resources, and configuration values.

// App-wide constants — aligned with Week 3 Lab Sheet specifications

// ── Data Source Selection ────────────────────────────────────────────────────
// Switch here to change which data source feeds the app.
// firestore:  primary — Cloud Firestore collection, requires network
// localAsset: fallback — bundled JSON, works 100% offline, no network needed
enum ApiSource { localAsset, firestore }

class AppConstants {
  AppConstants._();

  // ─── Active data source ────────────────────────────────────────────────────
  static const ApiSource activeSource = ApiSource.firestore;

  // Path to the bundled artworks JSON asset (used by localAsset source)
  static const String artworksDataPath = 'assets/data/artworks.json';

  // ─── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'RenaArt';
  static const String appTagline = 'The Digital Museum of the Renaissance';
  static const String appVersion = '1.0.0';
  static const String githubRepo = 'https://github.com/Jutatip124/RenaArt';

  // ─── Shared artwork settings ───────────────────────────────────────────────
  static const int imageMaxResolution = 1080;
  static const int maxOfflineArtworks = 10;

  // ─── Hive Box Names ────────────────────────────────────────────────────────
  static const String artworksBoxName = 'artworks_cache';
  static const String favoritesBoxName = 'user_favorites';
  static const String offlineBoxName = 'offline_artworks';
  static const String userBoxName = 'user_profile';

  // ─── SharedPreferences Keys ───────────────────────────────────────────────
  static const String keyThemeMode = 'pref_dark_mode';
  static const String keyHighFidelity = 'pref_high_fidelity';
  static const String keyUserId = 'user_id';
  static const String keyNickname = 'user_nickname';
  static const String keyUsername = 'user_username';
  static const String keyEmail = 'user_email';
  static const String keyIsGuest = 'user_is_guest';

  // ─── Validation Constants ───────────────────────────────────────────────────
  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 30;
  static const String usernamePattern = r'^[a-zA-Z0-9_]+$';
  static const int passwordMinLength = 8;

  // ─── Timing Constants ───────────────────────────────────────────────────────
  static const int authLoadDelayMs = 500;
  static const int usernameDebounceMs = 600;
  static const int resetEmailSnackbarSeconds = 5;

  // ─── Feed & Search Constants ────────────────────────────────────────────────
  static const int homeFeedDefaultCount = 200;
  static const int searchMaxCount = 300;
  static const int searchAvailableArtistsLimit = 8;
  static const int maxDescriptionLength = 2000;
}

class AppStrings {
  AppStrings._();

  // Navigation Labels
  static const String navHome = 'Home';
  static const String navSearch = 'Search';
  static const String navCollection = 'Collection';
  static const String navProfile = 'Profile';

  // Week 3 Spec: Periods (from student's own persona design)
  static const List<String> periods = [
    'For You',
    'Early Renaissance',
    'High Renaissance',
    'Northern Renaissance',
    'Mannerism',
    'Painting',
    'Sculpture',
    'Fresco',
    'Religious',
    'Portrait',
    'Mythology',
  ];

  // Popular artists from student's app concept
  static const List<String> popularArtists = [
    'Leonardo da Vinci',
    'Michelangelo',
    'Raphael',
    'Sandro Botticelli',
    'Titian',
    'Albrecht Dürer',
    'Caravaggio',
    'Giovanni Bellini',
    'Andrea Mantegna',
    'Tintoretto',
    'Jan van Eyck',
    'Correggio',
    'Domenico Ghirlandaio',
    'Lucas Cranach the Elder',
    'El Greco',
    'Donatello',
  ];

  // Art Form categories (museum standard classification)
  static const List<String> artForms = [
    'Painting',
    'Sculpture',
    'Fresco',
    'Drawing',
    'Print',
  ];

  // Subject categories for content-based filtering
  static const List<String> subjects = [
    'Religious',
    'Portrait',
    'Mythology',
    'Allegory',
    'Historical',
  ];

  // Region / origin for geographic filtering
  static const List<String> regions = [
    'Florence',
    'Rome',
    'Venice',
    'Milan',
    'Germany',
    'Flanders',
  ];

  // Week 3: Offline UI messages
  static const String offlineBanner = 'Viewing offline content';
  static const String offlineStorageFull =
      'Storage Full (10/10). Remove one artwork first.';
  static const String offlineStorageLabel = 'artworks saved';
}
