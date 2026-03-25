# Implementation Guide: Week 7-8-9 Refactoring

This guide explains how to apply the improvements identified in the lab sheet to the RenaArt codebase.

## Overview

The refactoring addresses three main areas:
1. **Code Quality** - Better error handling, validation, and service organization
2. **Security** - Enhanced protection against common web vulnerabilities
3. **Privacy** - PDPA compliance features (data export, deletion, transparency)

## New Services Added

### 1. LoggingService (`lib/services/logging_service.dart`)

**Purpose:** Replace silent error suppression with structured logging.

**Usage Example:**
```dart
import 'package:renaart/services/logging_service.dart';

final _log = LoggingService.instance;

// Log different severity levels
_log.debug('Detailed debug information');
_log.info('Informational message');
_log.warning('Non-critical issue');
_log.error('Critical error', error: e, stackTrace: stackTrace);

// Domain-specific logging
_log.authEvent('User signed in', userId: user.uid);
_log.dataOperation('Created profile', collection: 'users');
_log.networkError('API call failed', error: e);
```

**Integration Steps:**
1. Import `LoggingService` in files with error handling
2. Replace `catch (_) {}` with proper error logging:
   ```dart
   // BEFORE (Silent failure)
   try { await _db.saveProfile(profile); } catch (_) {}

   // AFTER (Proper logging)
   try {
     await _db.saveProfile(profile);
   } catch (e, stackTrace) {
     _log.error('Failed to save profile', error: e, stackTrace: stackTrace);
   }
   ```

### 2. ValidationService (`lib/services/validation_service.dart`)

**Purpose:** Centralized input validation with consistent error messages.

**Usage Example:**
```dart
import 'package:renaart/services/validation_service.dart';

final _validator = ValidationService.instance;

// Validate email
final result = _validator.validateEmail(email);
if (!result.isValid) {
  throw result.message!; // "Please enter a valid email address"
}

// Validate username
final usernameResult = _validator.validateUsername(username);
if (!usernameResult.isValid) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(usernameResult.message!)),
  );
  return;
}

// Validate bug report (detects PII)
final reportResult = _validator.validateBugReport(description);
if (reportResult.hasWarning) {
  // Show warning dialog to user
  await showDialog(...);
}
```

**Integration Steps:**
1. Import `ValidationService` in screens with user input
2. Add validation before submitting forms:
   ```dart
   // In login screen
   Future<void> _handleLogin() async {
     final emailValidation = _validator.validateEmail(_emailController.text);
     if (!emailValidation.isValid) {
       setState(() => _error = emailValidation.message);
       return;
     }

     final passwordValidation = _validator.validatePassword(_passwordController.text);
     if (!passwordValidation.isValid) {
       setState(() => _error = passwordValidation.message);
       return;
     }

     // Proceed with login
     await ref.read(authProvider.notifier).signIn(email, password);
   }
   ```

### 3. PrivacyService (`lib/services/privacy_service.dart`)

**Purpose:** PDPA compliance features (data export, deletion, transparency).

**Usage Example:**
```dart
import 'package:renaart/services/privacy_service.dart';

final _privacy = PrivacyService.instance;

// Export user data
Future<void> exportMyData() async {
  final userId = ref.read(authProvider)?.userId;
  if (userId == null) return;

  final jsonData = await _privacy.exportUserData(userId);

  // Download as file (web)
  final bytes = utf8.encode(jsonData);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'my_data_${DateTime.now().millisecondsSinceEpoch}.json')
    ..click();
  html.Url.revokeObjectUrl(url);
}

// Show data collection summary
void showPrivacyInfo() {
  final summary = _privacy.getDataCollectionSummary();
  // Display in dialog or page
}

// Get privacy summary for user
String getPrivacySummary() {
  final userId = ref.read(authProvider)?.userId ?? 'guest';
  return _privacy.generatePrivacySummary(userId);
}
```

**Integration Steps:**
1. Add "Export My Data" button in profile/settings screen
2. Add "Data & Privacy" information page
3. Update account deletion flow to use `clearAllLocalData()`

## Security Improvements

### 1. Security Headers (Already Applied)

**File:** `firebase.json`

Security headers have been added to protect against common web vulnerabilities:
- `X-Content-Type-Options: nosniff` - Prevents MIME sniffing attacks
- `X-Frame-Options: DENY` - Prevents clickjacking
- `X-XSS-Protection: 1; mode=block` - Enables browser XSS filter
- `Referrer-Policy` - Controls referrer information leakage
- `Permissions-Policy` - Disables unnecessary browser features

**No code changes needed** - These are applied automatically when you deploy to Firebase Hosting.

### 2. Firebase API Key Restrictions

**Manual Configuration Required:**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (`renaart-ded29`)
3. Go to Project Settings > General
4. Under "Your apps", find your Web app
5. Click on the API key (or "Manage API keys")
6. In Google Cloud Console, add Application restrictions:
   - Select "HTTP referrers (websites)"
   - Add:
     - `https://renaart-ded29.web.app/*`
     - `https://renaart-ded29.firebaseapp.com/*`
     - `http://localhost:*` (for development only)

**Important:** Without this restriction, anyone can use your Firebase API key to make requests.

### 3. Input Sanitization

**Current Implementation:** `ValidationService.sanitizeInput()`

Apply sanitization to all user-generated content before storing:

```dart
// In bug report submission
final sanitizedCategory = _validator.sanitizeInput(category);
final sanitizedDescription = _validator.sanitizeInput(description);
await _db.submitReport(userId, sanitizedCategory, sanitizedDescription);
```

## Critical Code Fixes

### 1. Improved Auth Notifier

**Reference:** `lib/features/home/providers/auth_notifier_improved.dart`

This file demonstrates the proper implementation of:
- Error logging instead of silent failures
- Input validation before operations
- Transaction safety for username updates
- Fixed account deletion race condition

**To Apply:**

Option A (Recommended for learning):
1. Review `auth_notifier_improved.dart`
2. Apply the patterns to `app_providers.dart` incrementally
3. Test each change thoroughly

Option B (Quick fix):
1. Replace `AuthNotifier` in `app_providers.dart` with `AuthNotifierImproved`
2. Update provider declaration
3. Test all auth flows

**Key Improvements:**

1. **Error Logging:**
   ```dart
   // BEFORE
   try { await _db.saveProfile(profile); } catch (_) {}

   // AFTER
   try {
     await _db.saveProfile(profile);
     _log.dataOperation('Saved user profile', collection: 'users');
   } catch (e, stackTrace) {
     _log.error('Failed to save profile', error: e, stackTrace: stackTrace);
   }
   ```

2. **Username Update Transaction Safety:**
   ```dart
   // AFTER - Claim new username first, then release old only on success
   bool newUsernameClaimed = false;
   try {
     await _db.claimUsername(newUsername, userId);
     newUsernameClaimed = true;
     await _db.saveProfile(updated);
     await _db.releaseUsername(oldUsername);
   } catch (e) {
     if (newUsernameClaimed) {
       await _db.releaseUsername(newUsername); // Rollback
     }
     rethrow;
   }
   ```

3. **Account Deletion Order Fix:**
   ```dart
   // BEFORE - Firestore first (can leave orphaned data)
   await _db.deleteProfile(uid);
   await fbUser.delete();

   // AFTER - Auth first (prevents orphaned data)
   await fbUser.delete(); // Invalidates session immediately
   try {
     await _db.deleteProfile(uid); // Cleanup, errors are logged but don't fail
   } catch (e) {
     _log.error('Firestore cleanup failed', error: e);
   }
   ```

### 2. Remove Hardcoded Delay

**File:** `app_providers.dart:103`

**Current Code:**
```dart
await Future.delayed(const Duration(milliseconds: 500));
```

**Problem:** Arbitrary delay is unreliable.

**Solution:** Use Firebase Auth state stream:
```dart
// In _load() method, instead of delay:
final auth = _auth;
if (auth == null) { /* handle */ }

// Option 1: Use current user (already available after init)
final fbUser = auth.currentUser;
if (fbUser != null) {
  await _handleFirebaseUser(fbUser);
  return;
}

// Option 2: Listen to auth state changes (better for real-time updates)
auth.authStateChanges().listen((user) {
  if (user != null) {
    _handleFirebaseUser(user);
  } else {
    state = null;
  }
});
```

## Testing Checklist

After implementing improvements:

- [ ] Test login with invalid email (should show validation error)
- [ ] Test registration with weak password (should show validation error)
- [ ] Test username update (should not leak old username on failure)
- [ ] Test account deletion (Firestore profile should be deleted)
- [ ] Test data export (should download JSON file)
- [ ] Test bug report with email in description (should show warning)
- [ ] Check browser console for errors (should see structured logs in dev mode)
- [ ] Test offline mode (should still work without Firestore)
- [ ] Check Firebase Console for security warnings
- [ ] Test with API key restrictions enabled

## Production Deployment Checklist

Before deploying to production:

- [ ] Enable Firebase API key restrictions
- [ ] Enable Firebase App Check
- [ ] Review Firestore security rules
- [ ] Test all security headers (use securityheaders.com)
- [ ] Add privacy policy page
- [ ] Add data export feature to UI
- [ ] Configure Firebase billing alerts
- [ ] Set up error monitoring (Crashlytics)
- [ ] Review all error messages (don't leak sensitive info)
- [ ] Test data deletion completely removes user data
- [ ] Document incident response procedures
- [ ] Get legal review of privacy policy

## Gradual Implementation Approach

**Week 1:**
1. Add LoggingService
2. Replace critical silent catches with logging
3. Deploy and monitor logs

**Week 2:**
1. Add ValidationService
2. Implement validation in login/registration screens
3. Test edge cases

**Week 3:**
1. Add PrivacyService
2. Implement data export feature
3. Update account deletion to clear all data

**Week 4:**
1. Apply auth notifier improvements
2. Fix username update transaction
3. Fix account deletion race condition
4. Final testing and deployment

## Rollback Plan

If issues occur after deployment:

1. **Immediate:** Revert to previous deployment via Firebase Hosting history
2. **Investigate:** Check error logs for failure patterns
3. **Fix:** Apply targeted fixes based on logs
4. **Test:** Thoroughly test fix in staging environment
5. **Deploy:** Gradual rollout with monitoring

## Support & Resources

- **Lab Sheet:** `WEEK_7-8-9_LAB_SHEET.md` - Detailed analysis of issues
- **Security Guide:** `SECURITY.md` - Security best practices
- **README:** Updated with security and privacy sections
- **Firebase Docs:** https://firebase.google.com/docs
- **Flutter Security:** https://docs.flutter.dev/security

## Questions?

For questions about implementation:
1. Review the lab sheet for detailed explanations
2. Check the improved auth notifier example
3. Review Flutter and Firebase documentation
4. Test changes incrementally

Remember: Security and privacy are ongoing concerns, not one-time fixes. Regular reviews and updates are essential.
