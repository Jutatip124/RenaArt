/// App-wide constants — aligned with Week 3 Lab Sheet specifications
class AppConstants {
  AppConstants._();

  // Data source toggle
  static const bool useMockData = true;

  // ─── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'RenaArt';
  static const String appTagline = 'The Digital Museum of the Renaissance';
  static const String studentId = '6631503124';
  static const String githubRepo = 'https://github.com/Jutatip124/RenaArt.git';

  // ─── Week 3 Spec: Met Museum API Endpoints ────────────────────────────────
  // Action: Search IDs  → GET /search?q=...&hasImages=true
  // Action: Get Artwork → GET /objects/{id}
  static const String metApiBase =
      'https://collectionapi.metmuseum.org/public/collection/v1';
  static const String metSearchEndpoint = '$metApiBase/search';
  static const String metObjectEndpoint = '$metApiBase/objects';

  // Week 3 Spec: Image resolution cap
  static const int imageMaxResolution = 1080;

  // Week 3 Spec: Offline limit = 10 artworks max
  static const int maxOfflineArtworks = 10;

  // ─── Hive Box Names (Week 3: Local Storage spec) ──────────────────────────
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

  // ─── Met Museum Department IDs for Renaissance artworks ──────────────────
  // departmentId=11 = European Paintings
  // departmentId=13 = Greek/Roman (for sculptures)
  static const String renaissanceSearchQuery =
      'renaissance painting';
  static const int europeanPaintingsDeptId = 11;

  // ─── Week 3 State Management: Global State fields ─────────────────────────
  // Global: User's Saved/Favorite Artworks (needed in Home, Search, Detail, Collection)
  // Global: Offline Artwork Availability (needed across all screens)
  // Local:  Search query text, filter selections (period, medium, artist)
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
    'All',
    'Early Renaissance',
    'High Renaissance',
    'Northern Renaissance',
    'Mannerism',
    'Flemish',
  ];

  // Popular artists from student's app concept
  static const List<String> popularArtists = [
    'Leonardo da Vinci',
    'Michelangelo',
    'Raphael',
    'Sandro Botticelli',
    'Jan van Eyck',
    'Titian',
    'Albrecht Dürer',
    'Fra Angelico',
  ];

  // Mediums for filters
  static const List<String> mediums = [
    'Painting',
    'Sculpture',
    'Fresco',
    'Drawing',
    'Print',
    'Tapestry',
  ];

  // Week 3: Offline UI messages
  static const String offlineBanner = 'Viewing offline content';
  static const String offlineStorageFull =
      'Storage Full (10/10). Remove one artwork first.';
  static const String offlineStorageLabel = 'artworks saved';
}
