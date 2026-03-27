import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive user data (PII).
/// Uses platform-specific encryption (Keychain on iOS, EncryptedSharedPreferences on Android).
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
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyEmail, value: email),
      _storage.write(key: _keyUsername, value: username),
    ]);
  }

  /// Returns decrypted user data as a map, or null if not found.
  Future<Map<String, String>?> loadSecureUserData() async {
    final results = await Future.wait([
      _storage.read(key: _keyUserId),
      _storage.read(key: _keyEmail),
      _storage.read(key: _keyUsername),
    ]);

    final userId = results[0];
    final email = results[1];
    final username = results[2];

    if (userId == null) return null;

    return {
      'userId': userId,
      'email': email ?? '',
      'username': username ?? '',
    };
  }

  /// Wipes all encrypted storage data.
  Future<void> clearSecureData() async {
    await _storage.deleteAll();
  }
}
