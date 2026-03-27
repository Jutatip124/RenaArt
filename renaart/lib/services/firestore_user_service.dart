import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Saves and loads user profiles from Firestore `users` collection.
class FirestoreUserService {
  FirestoreUserService._();
  static final instance = FirestoreUserService._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users');
  CollectionReference<Map<String, dynamic>> get _usernames =>
      FirebaseFirestore.instance.collection('usernames');
  CollectionReference<Map<String, dynamic>> get _reports =>
      FirebaseFirestore.instance.collection('reports');

  Future<void> saveProfile(UserModel user) async {
    try {
      await _col.doc(user.userId).set({
        'nickname': user.nickname,
        'username': user.username,
        'email': user.email,
        'createdAt': user.createdAt,
        'darkMode': user.preferences.darkMode,
        'highFidelity': user.preferences.highFidelityMode,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreUserService.saveProfile failed: $e');
    }
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
    } catch (e) {
      debugPrint('FirestoreUserService.loadProfile failed: $e');
      return null;
    }
  }

  /// Check if a username is available (case-insensitive).
  /// Returns true on error (optimistic — registration will verify again).
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final doc = await _usernames.doc(username.toLowerCase()).get();
      return !doc.exists;
    } catch (e) {
      debugPrint('FirestoreUserService.isUsernameAvailable failed: $e');
      return true;
    }
  }

  /// Claim a username for a user. Returns false if already taken.
  Future<bool> claimUsername(String username, String userId) async {
    try {
      final key = username.toLowerCase();
      final doc = await _usernames.doc(key).get();
      if (doc.exists && doc.data()?['userId'] != userId) return false;
      await _usernames.doc(key).set({'userId': userId});
      return true;
    } catch (e) {
      debugPrint('FirestoreUserService.claimUsername failed: $e');
      return false;
    }
  }

  /// Release a previously claimed username.
  Future<void> releaseUsername(String username) async {
    try {
      await _usernames.doc(username.toLowerCase()).delete();
    } catch (e) {
      debugPrint('FirestoreUserService.releaseUsername failed: $e');
    }
  }

  /// Delete a user's profile from Firestore.
  Future<void> deleteProfile(String uid) async {
    try {
      await _col.doc(uid).delete();
    } catch (e) {
      debugPrint('FirestoreUserService.deleteProfile failed: $e');
    }
  }

  /// Delete all reports submitted by this user
  Future<void> deleteUserReports(String userId) async {
    try {
      final querySnapshot = await _reports.where('userId', isEqualTo: userId).get();
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('FirestoreUserService.deleteUserReports failed: $e');
    }
  }

  /// Submit a problem report to Firestore.
  Future<void> submitReport(String userId, String category, String description) async {
    try {
      await _reports.add({
        'userId': userId,
        'category': category,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      rethrow;
    }
  }
}
