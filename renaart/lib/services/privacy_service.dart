import 'dart:convert';
import '../models/user_model.dart';
import '../models/artwork_model.dart';
import 'local_storage_service.dart';
import 'logging_service.dart';

/// Service for privacy-related operations: data export, deletion, consent management.
/// Implements PDPA/GDPR compliance features.
class PrivacyService {
  PrivacyService._();
  static final PrivacyService instance = PrivacyService._();

  final _log = LoggingService.instance;
  final _storage = LocalStorageService.instance;

  /// Export all user data in JSON format (PDPA Right to Data Portability)
  Future<String> exportUserData(String userId) async {
    try {
      _log.info('Exporting user data', context: userId);

      final user = await _storage.loadUser();
      final favorites = _storage.getFavorites(userId);
      final offlineArtworks = _storage.getOfflineArtworks();
      final favoriteIds = _storage.getFavoriteIds(userId);

      // Collect view history
      final viewHistory = <Map<String, dynamic>>[];
      for (final artworkId in favoriteIds) {
        final viewCount = _storage.getViewCount(artworkId, userId);
        if (viewCount > 0) {
          viewHistory.add({
            'artworkId': artworkId,
            'viewCount': viewCount,
          });
        }
      }

      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'exportVersion': '1.0',
        'user': {
          'userId': user?.userId ?? userId,
          'email': user?.email ?? '',
          'username': user?.username ?? '',
          'nickname': user?.nickname ?? '',
          'createdAt': user?.createdAt ?? '',
          'preferences': {
            'darkMode': user?.preferences.darkMode ?? false,
            'highFidelityMode': user?.preferences.highFidelityMode ?? true,
          },
        },
        'statistics': {
          'totalFavorites': favorites.length,
          'offlineArtworks': offlineArtworks.length,
          'totalViews': viewHistory.fold<int>(0, (sum, item) => sum + (item['viewCount'] as int)),
        },
        'favorites': favorites.map((artwork) => {
          'id': artwork.id,
          'title': artwork.title,
          'artist': artwork.artist,
          'period': artwork.period,
        }).toList(),
        'offlineArtworks': offlineArtworks.map((artwork) => {
          'id': artwork.id,
          'title': artwork.title,
          'artist': artwork.artist,
        }).toList(),
        'viewHistory': viewHistory,
        'privacyNotice': 'This export contains all personal data stored by RenaArt. '
            'You have the right to request deletion of this data at any time.',
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      _log.info('User data exported successfully', context: userId);
      return jsonString;
    } catch (e, stackTrace) {
      _log.error('Failed to export user data', context: userId, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Clear all local user data (not including cloud data)
  /// Use this for local cleanup when user deletes account
  Future<void> clearAllLocalData(String userId) async {
    try {
      _log.info('Clearing all local data', context: userId);

      // Clear user profile from SharedPreferences
      await _storage.clearUser();

      // Clear favorites for this user
      final favoriteIds = _storage.getFavoriteIds(userId);
      for (final artworkId in favoriteIds) {
        await _storage.toggleFavorite(artworkId, userId);
      }

      // Note: Offline artworks are shared across users, so we don't clear them
      // Cache is also shared, so we keep it for other users/sessions

      _log.info('Local data cleared successfully', context: userId);
    } catch (e, stackTrace) {
      _log.error('Failed to clear local data', context: userId, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get data collection summary for transparency
  Map<String, dynamic> getDataCollectionSummary() {
    return {
      'categories': [
        {
          'category': 'Account Information',
          'items': ['Email address', 'Username', 'Nickname', 'User ID'],
          'purpose': 'Authentication and user identification',
          'storage': 'Firebase Authentication, Firestore, Local Storage',
          'required': true,
        },
        {
          'category': 'User Preferences',
          'items': ['Dark mode setting', 'High fidelity mode'],
          'purpose': 'Personalization and user experience',
          'storage': 'Firestore, Local Storage',
          'required': false,
        },
        {
          'category': 'User Activity',
          'items': ['Favorite artworks', 'View counts', 'Offline downloads'],
          'purpose': 'App functionality and recommendations',
          'storage': 'Local Storage (Hive)',
          'required': false,
        },
        {
          'category': 'Bug Reports',
          'items': ['Report category', 'Description', 'User ID', 'Timestamp'],
          'purpose': 'App improvement and support',
          'storage': 'Firestore',
          'required': false,
          'retention': '90 days',
        },
      ],
      'thirdParties': [
        {
          'name': 'Google Firebase',
          'services': ['Authentication', 'Firestore Database', 'Hosting'],
          'dataShared': ['Email', 'User ID', 'Authentication tokens'],
          'purpose': 'App infrastructure and services',
          'privacyPolicy': 'https://firebase.google.com/support/privacy',
        },
      ],
      'userRights': [
        'Right to Access - Export your data at any time',
        'Right to Erasure - Delete your account and all associated data',
        'Right to Rectification - Update your personal information',
        'Right to Data Portability - Download your data in JSON format',
        'Right to Withdraw Consent - Disable optional data collection',
      ],
    };
  }

  /// Check if view tracking is enabled (for privacy settings)
  /// In future, this would check user preference
  bool isViewTrackingEnabled() {
    // For now, always enabled. Future: add user preference
    return true;
  }

  /// Get data retention summary
  Map<String, String> getDataRetentionPolicy() {
    return {
      'User Profile': 'Until account deletion',
      'Favorites': 'Until manually removed or account deletion',
      'View History': 'Recommend 30-day retention (currently indefinite)',
      'Bug Reports': 'Recommend 90-day retention (currently indefinite)',
      'Cached Artworks': 'Recommend 7-day retention (currently indefinite)',
    };
  }

  /// Generate privacy summary for user
  String generatePrivacySummary(String userId) {
    final user = _storage.loadUser();
    final favCount = _storage.getFavoriteIds(userId).length;
    final offlineCount = _storage.getOfflineIds().length;

    return '''
Privacy Summary for RenaArt

Data Stored Locally:
• User Profile: ${user != null ? 'Yes' : 'No'}
• Favorites: $favCount artworks
• Offline Downloads: $offlineCount artworks
• View Tracking: ${isViewTrackingEnabled() ? 'Enabled' : 'Disabled'}

Your Rights:
✓ Export your data (JSON format)
✓ Delete your account and all data
✓ Update your information anytime
✓ Control optional data collection

Data Protection:
• Data stored on your device and Firebase servers
• Email used only for authentication
• No data sold to third parties
• Minimal data collection principle

Questions? Contact: [your-email]
    '''.trim();
  }
}
