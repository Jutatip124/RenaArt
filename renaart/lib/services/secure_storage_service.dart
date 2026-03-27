import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage service for sensitive user data (PII).
/// Uses platform-specific encryption (Keychain on iOS, EncryptedSharedPreferences on Android).
/// Falls back to SharedPreferences on Web (uses localStorage, persistent across sessions).
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _keyUserId = 'secure_user_id';
  static const _keyEmail = 'secure_email';
  static const _keyUsername = 'secure_username';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Encrypts and stores PII (userId, email, username).
  Future<void> saveSecureUserData({
    required String userId,
    required String email,
    required String username,
  }) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyUsername, username);
      return;
    }
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyEmail, value: email),
      _storage.write(key: _keyUsername, value: username),
    ]);
  }

  /// Returns decrypted user data as a map, or null if not found.
  Future<Map<String, String>?> loadSecureUserData() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyUserId);
      if (userId == null) return null;
      return {
        'userId': userId,
        'email': prefs.getString(_keyEmail) ?? '',
        'username': prefs.getString(_keyUsername) ?? '',
      };
    }

    final results = await Future.wait([
      _storage.read(key: _keyUserId),
      _storage.read(key: _keyEmail),
      _storage.read(key: _keyUsername),
    ]);

    final userId = results[0];
    if (userId == null) return null;

    return {
      'userId': userId,
      'email': results[1] ?? '',
      'username': results[2] ?? '',
    };
  }

  /// Wipes all encrypted storage data.
  Future<void> clearSecureData() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyUsername);
      return;
    }
    await _storage.deleteAll();
  }
}
