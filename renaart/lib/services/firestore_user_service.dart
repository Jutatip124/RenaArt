import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Saves and loads user profiles from Firestore `users` collection.
class FirestoreUserService {
  FirestoreUserService._();
  static final instance = FirestoreUserService._();

  late final _col = FirebaseFirestore.instance.collection('users');

  Future<void> saveProfile(UserModel user) async {
    await _col.doc(user.userId).set({
      'nickname': user.nickname,
      'username': user.username,
      'email': user.email,
      'createdAt': user.createdAt,
      'darkMode': user.preferences.darkMode,
      'highFidelity': user.preferences.highFidelityMode,
    }, SetOptions(merge: true));
  }

  Future<UserModel?> loadProfile(String uid, String email) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) return null;
      final d = doc.data()!;
      return UserModel(
        userId: uid,
        name: d['nickname'] ?? '',
        nickname: d['nickname'] ?? 'Art Lover',
        username: d['username'] ?? email.split('@').first,
        email: email,
        createdAt: d['createdAt'] ?? '',
        preferences: UserPreferences(
          darkMode: d['darkMode'] ?? false,
          highFidelityMode: d['highFidelity'] ?? true,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
