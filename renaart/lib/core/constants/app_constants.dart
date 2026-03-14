// App-wide constants — aligned with Week 3 Lab Sheet specifications

// ── Data Source Selection ────────────────────────────────────────────────────
// Switch here to change which API feeds the app.
// localAsset:          FASTEST — bundled JSON, works 100% offline, no network needed
// ArtInstituteChicago: no API key, fast (single-request), 400k+ works
// Rijksmuseum:         free API key at data.rijksmuseum.nl, Dutch/Flemish focus
// MetMuseum:           original source, slowest (two-step ID batch)
// Mock:                generated seed data (no internet required)
enum ApiSource { localAsset, firestore, artInstituteChicago, rijksmuseum, metMuseum, mock }

class AppConstants {
  AppConstants._();

  // ─── Active data source ────────────────────────────────────────────────────
  static const ApiSource activeSource = ApiSource.firestore;

  // Path to the bundled artworks JSON asset (used by localAsset source)
  static const String artworksDataPath = 'assets/data/artworks.json';

  // Legacy toggle kept for backward compat — derived from activeSource
  static bool get useMockData => activeSource == ApiSource.mock;

  // ─── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'RenaArt';
  static const String appTagline = 'The Digital Museum of the Renaissance';
  static const String appVersion = '1.0.0';
  static const String studentId = '6631503124';
  static const String githubRepo = 'https://github.com/Jutatip124/RenaArt';

  // ─── Art Institute of Chicago API (no auth required) ──────────────────────
  // Docs: https://api.artic.edu/docs/
  // One-request search: returns full objects + image_id in a single call
  static const String aicApiBase = 'https://api.artic.edu/api/v1';
  static const String aicImageBase = 'https://www.artic.edu/iiif/2';
  // Image size helpers:  /full/843,/0/default.jpg  (large)
  //                      /full/400,/0/default.jpg  (thumbnail)
  static const String aicImageLarge = '/full/843,/0/default.jpg';
  static const String aicImageThumb = '/full/400,/0/default.jpg';
  static const List<String> aicFields = [
    'id', 'title', 'artist_display', 'artist_id',
    'date_display', 'date_start', 'date_end',
    'medium_display', 'dimensions',
    'image_id', 'thumbnail',
    'artwork_type_title', 'classification_title',
    'place_of_origin', 'is_public_domain',
    'department_title', 'style_title', 'subject_titles',
  ];

  // ─── Rijksmuseum API (free key: data.rijksmuseum.nl) ──────────────────────
  // Docs: https://data.rijksmuseum.nl/object-metadata/api/
  // Set RIJKS_API_KEY as a GitHub Secret or in android/local.properties
  static const String rijksApiBase =
      'https://www.rijksmuseum.nl/api/en/collection';
  static const String rijksApiKey = String.fromEnvironment(
    'RIJKS_API_KEY',
    defaultValue: 'YOUR_RIJKS_KEY', // replace or inject via --dart-define
  );

  // ─── Met Museum API Endpoints (legacy / fallback) ─────────────────────────
  static const String metApiBase =
      'https://collectionapi.metmuseum.org/public/collection/v1';
  static const String metSearchEndpoint = '$metApiBase/search';
  static const String metObjectEndpoint = '$metApiBase/objects';

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

  // ─── Met Museum Department IDs ────────────────────────────────────────────
  static const String renaissanceSearchQuery = 'renaissance painting';
  static const int europeanPaintingsDeptId = 11;
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

  // Art Form categories (museum standard classification)
  static const List<String> artForms = [
    'Painting',
    'Sculpture',
    'Drawing',
    'Print',
    'Decorative Arts',
  ];

  // Subject categories for content-based filtering
  static const List<String> subjects = [
    'Religious',
    'Mythology',
    'Portrait',
    'Historical',
    'Nude / Anatomy',
    'Allegory',
  ];

  // Week 3: Offline UI messages
  static const String offlineBanner = 'Viewing offline content';
  static const String offlineStorageFull =
      'Storage Full (10/10). Remove one artwork first.';
  static const String offlineStorageLabel = 'artworks saved';
}
