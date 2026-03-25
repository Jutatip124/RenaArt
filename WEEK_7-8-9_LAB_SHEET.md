# Week 7-8-9 Lab Sheet: Refactor-Security-PDPA

**StudentName:** Jutatip Sriputhon
**StudentID:** 6631503124
**Project Name:** RenaArt

---

## Objective

To critically analyze the RenaArt Mini Project by identifying weaknesses and proposing practical solutions in three key areas:

1. Code Review (Maintainability & Quality)
2. Security (Protection Against Attacks)
3. Privacy (PDPA Compliance & Ethical Data Use)

---

## Part 1: Code Review Analysis

### Task: Identify Code Smells & Maintainability Issues

| # | Description | Why It's a Problem | Proposed Solution |
|---|-------------|-------------------|-------------------|
| 1 | **Silent Error Suppression** - Throughout the codebase, errors are caught and ignored with empty catch blocks (e.g., `catch (_) {}` in `app_providers.dart:43,63,114-117,149-150,154,358-360,372,377`) | This makes debugging extremely difficult. When errors occur, they fail silently without any indication of what went wrong. This can lead to unexpected behavior and make it impossible to diagnose production issues. | Implement proper logging service using `logger` package. Replace all `catch (_) {}` with meaningful error logging and user-friendly error messages where appropriate. |
| 2 | **Magic Numbers and Hardcoded Delays** - `await Future.delayed(const Duration(milliseconds: 500))` in `app_providers.dart:103` without clear explanation | Hardcoded delays are fragile and make the code difficult to maintain. The 500ms delay is arbitrary and may not work on all devices/network conditions. The comment says "wait for Firebase Auth's internal IndexedDB operations to settle" but this is unreliable. | Replace with proper Firebase Auth state listener using `authStateChanges()` stream. Add named constants for any necessary timeouts with clear documentation of why they're needed. |
| 3 | **Mixed Concerns in Services** - `LocalStorageService` handles both Hive (offline/favorites) and SharedPreferences (user profile) in a single class | Violates Single Responsibility Principle. The service has too many responsibilities, making it harder to test, maintain, and reason about. Changes to one storage mechanism can affect the other. | Split into separate services: `HiveStorageService` for artwork/favorites/offline data and `UserPreferencesService` for user profile data. Each should have a clear, focused responsibility. |
| 4 | **Incomplete Error Handling in Username Operations** - Username claim/release operations in `app_providers.dart:308-313` have race conditions and no rollback mechanism | If `claimUsername` succeeds but `releaseUsername` fails, the old username remains claimed forever, causing username leaks. Network failures during the operation can leave the system in an inconsistent state. | Implement transaction-like behavior with proper rollback. Use Firestore batch operations or transactions. Add retry logic with exponential backoff for network failures. Log all username operations for audit trail. |
| 5 | **No Validation Layer** - Input validation happens inline in UI screens, duplicated across multiple files | Business logic mixed with UI code violates separation of concerns. Validation rules are scattered and duplicated, making them hard to maintain and test. Different screens may validate the same data differently. | Create dedicated validation service (`ValidationService`) with reusable validators for email, password, username, etc. Centralize all validation logic to ensure consistency and enable unit testing. |

### Reflection

**Which part of your code was hardest to understand and why?**

The authentication flow in `AuthNotifier` was the hardest to understand because:

1. **Complex State Management**: The `_load()` method has multiple fallback paths with silent error handling, making it difficult to trace execution flow
2. **Timing Issues**: The hardcoded 500ms delay suggests there's a race condition with Firebase initialization, but it's not clearly documented
3. **Multiple State Sources**: User state can come from Firebase Auth, Firestore, or SharedPreferences, and the sync logic between these sources is implicit
4. **Silent Failures**: Errors are swallowed everywhere, so it's impossible to know when operations fail or why fallback paths are taken

The code would be much clearer with:
- Explicit state machine for auth states (loading, authenticated, anonymous, error)
- Proper logging of all state transitions
- Clear documentation of fallback scenarios
- Event-driven architecture instead of polling/delays

---

## Part 2: Security Analysis

### Task: Identify Security Vulnerabilities

| # | Issue | Description | Risk Level | Proposed Solution |
|---|-------|-------------|------------|-------------------|
| 1 | **Exposed Firebase API Key** | Firebase web API key (`AIzaSyCoBUU9mGWjnbqM3idEjL1znOJtCn5zZAI`) is hardcoded in `firebase_options.dart:56`. While Firebase web API keys are meant to be public, they should be restricted by domain/app identifier in Firebase Console. | **HIGH** | 1. Add Firebase API key restrictions in Firebase Console (restrict to authorized domains only). 2. Add environment-based configuration using `--dart-define` for different environments. 3. Document in README that API key restrictions are critical before production deployment. |
| 2 | **No Local Data Encryption** | User data (email, username, userId) is stored in plain text in SharedPreferences (browser LocalStorage) and Hive (IndexedDB). Any browser extension or XSS attack can read this data. | **MEDIUM** | 1. Implement encryption for sensitive data in SharedPreferences using `flutter_secure_storage` or `encrypt` package. 2. For web platform, use Web Crypto API for client-side encryption. 3. Encrypt Hive boxes containing user-specific data. 4. Add security documentation warning about browser storage limitations. |
| 3 | **Email Enumeration via Password Reset** | `resetPassword()` in `app_providers.dart:275-286` reveals whether an email exists in the system through different error messages or timing attacks. | **MEDIUM** | Always return the same success message regardless of whether email exists: "If this email is registered, you will receive a password reset link." This prevents attackers from discovering registered emails. Add rate limiting documentation. |
| 4 | **Missing Content Security Policy** | No CSP headers configured in `firebase.json` or web deployment, making the app vulnerable to XSS attacks via injected scripts. | **MEDIUM** | Add CSP headers to `firebase.json` hosting configuration: `"headers": [{"source": "**", "headers": [{"key": "Content-Security-Policy", "value": "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://apis.google.com; style-src 'self' 'unsafe-inline';"}]}]`. Configure strict CSP that allows only necessary sources. |
| 5 | **Account Deletion Race Condition** | In `deleteAccount()` (`app_providers.dart:383-411`), Firestore data is deleted before Firebase Auth account. Network failure after Firestore deletion but before Auth deletion leaves orphaned Firestore profile data. | **LOW** | Reverse the order: delete from Firebase Auth first (authoritative source), then clean up Firestore data. Auth deletion automatically invalidates the session, preventing further access. Add compensating transaction to clean up Firestore profiles for deleted auth accounts. |

### Scenario Question: If a hacker decompiles your app, what sensitive data can they access?

**Accessible Data:**

1. **Firebase Configuration** - Complete Firebase project credentials (API key, project ID, app ID). While these are meant to be public for web apps, unrestricted keys could allow unauthorized usage.

2. **API Endpoints & Structure** - All Firestore collection paths (`users`, `artworks`, `usernames`, `reports`) are visible in the code, allowing attackers to understand the data model.

3. **Local Storage Data** - If attacker gains access to the user's browser:
   - User email, username, userId (plaintext in localStorage)
   - Favorite artwork IDs and view counts (Hive/IndexedDB)
   - Offline downloaded artwork data
   - User preferences (dark mode, high fidelity settings)

4. **Business Logic** - All client-side validation rules, username generation patterns, error handling flows, which could help craft targeted attacks.

**NOT Accessible (Protected by Firebase):**
- User passwords (hashed by Firebase Auth)
- Other users' data (protected by Firestore security rules)
- Firebase Admin SDK credentials (server-side only)

**Mitigation:**
The real protection comes from server-side security (Firestore rules), which are properly implemented. However, sensitive local data should be encrypted to prevent theft via browser compromise.

---

## Part 3: Privacy & PDPA Analysis

### Task: Identify Privacy Risks

| Data Collected | Necessary? | Risk Level | Proposed Action |
|----------------|-----------|------------|-----------------|
| Email Address | **Yes** - Required for account recovery and authentication | **MEDIUM** - PII that could be used for phishing if leaked | Store encrypted locally. Add email privacy notice. Implement email verification. Allow users to opt-out of marketing emails (if added). |
| Username | **Yes** - Core feature for user identity in social features | **LOW** - Public identifier chosen by user | Keep as-is but add privacy notice that usernames are public. Allow username changes with proper audit trail. |
| User ID (Firebase UID) | **Yes** - Essential for authentication and data scoping | **LOW** - Auto-generated, not personally identifiable | Keep as-is. Never expose in URLs or logs. |
| Nickname/Display Name | **Yes** - User personalization | **LOW** - User-controlled, can be pseudonym | Keep as-is but allow users to change freely. |
| Artwork View Count | **Questionable** - Used for "Recently Viewed" but stored indefinitely | **LOW** - Behavior tracking | Add data retention policy: only keep last 30 days of view history. Add setting to disable view tracking. Provide clear notice about tracking. |
| Favorite Artwork IDs | **Yes** - Core feature (favorites collection) | **LOW** - User preferences | Keep as-is but ensure covered by privacy policy. |
| Dark Mode Preference | **No** - Could use system preference instead | **VERY LOW** - Minimal privacy impact | Allow syncing but respect system preference by default. Make opt-in. |
| High Fidelity Mode | **Questionable** - Could be inferred from device capability | **VERY LOW** - Minimal privacy impact | Consider removing or making local-only (no sync to Firestore). |
| Firebase Analytics Data | **No** - `measurementId` present but analytics not explicitly used | **MEDIUM** - Third-party tracking, IP addresses, user behavior | Explicitly disable Firebase Analytics or add prominent opt-in consent with clear explanation of what's collected. |
| Bug Reports (category, description) | **Yes** - For app improvement | **MEDIUM** - May contain sensitive user input | Add warning before submission: "Do not include personal information." Auto-scan for email/phone patterns and warn user. Add retention policy (delete after 90 days). |

### PDPA Compliance Questions

**1. What is the purpose of each data collected?**

| Data | Purpose | Legal Basis (PDPA) |
|------|---------|-------------------|
| Email | Authentication, account recovery, unique identifier | Contractual necessity (cannot provide service without it) |
| Username | User identity, social features (future) | Contractual necessity + Legitimate interest |
| Nickname | Personalization | Consent (optional field) |
| View Count | User experience (recently viewed feature) | Legitimate interest (can be disabled) |
| Favorites | Core feature - save artworks | Contractual necessity |
| Preferences (theme, fidelity) | User experience enhancement | Consent (optional) |
| Bug Reports | Service improvement, support | Legitimate interest + Consent (explicit action) |

**2. Can your system support Right to Erasure (Delete User Data)?**

**Current State:** PARTIAL

- ✅ **Firebase Auth Account**: Can be deleted via `deleteAccount()` method
- ✅ **Firestore User Profile**: Deleted when account is deleted
- ✅ **Firestore Username Claim**: Released when account is deleted
- ❌ **Local Storage Data**: NOT cleared when Firestore deletion happens (only cleared on successful auth deletion)
- ❌ **Hive Data (favorites, view counts)**: NOT cleared when deleting account
- ❌ **Bug Reports**: Stored indefinitely with userId, not deleted on account deletion
- ❌ **Data Export**: No mechanism to export user data before deletion

**Required Improvements:**
1. Implement complete data deletion that removes ALL user data from all systems
2. Add "Download My Data" feature (JSON export of profile, favorites, view history)
3. Delete or anonymize bug reports when user deletes account (replace userId with "deleted_user")
4. Add confirmation dialog showing exactly what data will be deleted
5. Provide 30-day account recovery period (soft delete) as best practice

**3. Are you collecting any Sensitive Data (e.g., health, biometrics)?**

**NO.** The app only collects:
- Authentication data (email, password hash via Firebase)
- User preferences (username, nickname, theme)
- Artwork interaction data (favorites, views)

No sensitive personal data categories under PDPA:
- ❌ Racial/ethnic origin
- ❌ Political opinions
- ❌ Religious beliefs
- ❌ Health data
- ❌ Biometric data
- ❌ Sexual orientation
- ❌ Criminal records
- ❌ Financial data
- ❌ Location data (no GPS tracking)

However, email addresses are PII and must be protected according to PDPA general provisions.

### Design Improvement: Privacy by Design

**Data Minimization:**
1. Remove unnecessary data collection:
   - Don't sync theme preference to Firestore (keep local-only)
   - Don't sync high fidelity setting (infer from device)
   - Remove Firebase Analytics measurement ID or add explicit opt-in

2. Implement data retention policies:
   - View history: 30-day retention with auto-cleanup
   - Bug reports: 90-day retention, then auto-delete
   - Cached artworks: Clear cache older than 7 days

3. Collect data only when needed:
   - Don't create Firestore profile for guest users
   - Don't track views for guest mode

**Explicit Consent:**
1. Add Privacy Policy page accessible from login/register
2. Add consent checkbox on registration: "I agree to the Privacy Policy and Terms of Service"
3. Add optional analytics consent: "Help improve RenaArt by sharing anonymous usage data"
4. Add data processing notice: "Your email will be used only for authentication and account recovery"

**Privacy by Design Architecture:**
1. Local-first approach: Keep sensitive data on device, sync only what's necessary
2. Encryption layer: Encrypt all local PII (email, username)
3. Data portability: Add export feature (JSON format)
4. Transparency: Add "Data & Privacy" settings page showing:
   - What data is collected
   - Where it's stored
   - How long it's kept
   - How to delete it
5. User control: Add granular privacy settings:
   - Toggle view tracking on/off
   - Toggle data sync to Firestore on/off
   - Clear all local data button

---

## Part 4: Integrated Solution Plan

### 1. Code Improvement Plan

**Priority 1: Error Handling & Logging**
- [ ] Add `logger` package for structured logging
- [ ] Create `LoggingService` with different log levels (debug, info, warning, error)
- [ ] Replace all `catch (_) {}` with proper error logging
- [ ] Add error tracking integration (e.g., Sentry or Firebase Crashlytics)
- [ ] Create user-facing error messages separate from technical logs

**Priority 2: Validation Layer**
- [ ] Create `ValidationService` class with reusable validators
- [ ] Add validators for: email, password, username, nickname
- [ ] Add input sanitization for user-generated content (bug reports)
- [ ] Add unit tests for all validators

**Priority 3: Service Separation**
- [ ] Split `LocalStorageService` into `HiveStorageService` and `UserPreferencesService`
- [ ] Remove hardcoded delays, replace with proper async state management
- [ ] Add proper state machine for auth flow (loading, authenticated, guest, error)
- [ ] Add named constants for all magic numbers and timeouts

**Priority 4: Transaction Safety**
- [ ] Implement rollback mechanism for username changes
- [ ] Add Firestore batch operations for multi-step writes
- [ ] Fix account deletion race condition (delete auth first, then Firestore)
- [ ] Add idempotency keys for critical operations

### 2. Security Hardening Plan

**Priority 1: API Key Security**
- [ ] Add Firebase API key restrictions in Firebase Console (domain whitelist)
- [ ] Add app check for additional security layer
- [ ] Document API key restriction setup in README
- [ ] Add environment variables for different deployment environments

**Priority 2: Data Encryption**
- [ ] Add `flutter_secure_storage` package
- [ ] Encrypt email and username in local storage
- [ ] Add encryption key management (use device keychain/keystore)
- [ ] Update data migration for existing users

**Priority 3: Security Headers & CSP**
- [ ] Add Content-Security-Policy header to Firebase hosting
- [ ] Add X-Frame-Options, X-Content-Type-Options headers
- [ ] Configure CORS properly in Firestore
- [ ] Add security.txt file for responsible disclosure

**Priority 4: Input Validation & Output Encoding**
- [ ] Add input sanitization for all user inputs (bug reports, nicknames, usernames)
- [ ] Add rate limiting documentation and client-side throttling
- [ ] Implement email enumeration protection (generic error messages)
- [ ] Add CAPTCHA for sensitive operations if abuse detected

**Priority 5: Security Documentation**
- [ ] Create SECURITY.md with security best practices
- [ ] Document threat model and security assumptions
- [ ] Add security testing checklist
- [ ] Create incident response plan

### 3. Privacy Compliance Plan

**Priority 1: Privacy Policy & Consent**
- [ ] Create comprehensive Privacy Policy page
- [ ] Add Terms of Service page
- [ ] Add consent checkbox on registration
- [ ] Add cookie/storage notice for web app
- [ ] Make consent granular (required vs. optional data)

**Priority 2: Data Subject Rights**
- [ ] Implement "Download My Data" feature (JSON export)
- [ ] Implement "Delete My Data" feature (complete erasure)
- [ ] Add 30-day account recovery period (soft delete)
- [ ] Anonymize bug reports on account deletion
- [ ] Add audit log for data access/changes

**Priority 3: Data Minimization**
- [ ] Remove unnecessary data collection (theme sync, analytics)
- [ ] Implement data retention policies (view history: 30 days, reports: 90 days)
- [ ] Add setting to disable view tracking
- [ ] Make guest mode fully anonymous (no tracking)
- [ ] Add cache cleanup for old data

**Priority 4: Privacy Controls**
- [ ] Add "Data & Privacy" settings page
- [ ] Add toggles for optional data collection
- [ ] Add "Clear Local Data" button
- [ ] Show what data is stored and where
- [ ] Add data processing transparency notice

**Priority 5: Third-Party Compliance**
- [ ] Disable Firebase Analytics by default, add opt-in
- [ ] Audit all third-party SDKs for data sharing
- [ ] Add third-party data processor list to privacy policy
- [ ] Ensure GDPR/PDPA compliance for all processors

---

## Final Reflection

### 1. What is the most dangerous mistake AI made in your code?

**Silent Error Suppression Everywhere**

The most dangerous pattern is the widespread use of empty catch blocks (`catch (_) {}`), particularly in critical authentication and data synchronization flows. This was likely AI-generated to make the code "work" without crashes, but it creates severe problems:

**Why it's dangerous:**
- **Invisible Failures**: Firestore writes, username claims, and profile updates can fail silently, leaving the system in an inconsistent state
- **Impossible Debugging**: When users report issues, there are no logs to diagnose what went wrong
- **Data Loss**: Failed writes to Firestore mean user data changes are lost without notification
- **Security Implications**: Failed security operations (like account deletion or username release) could leave orphaned data or locked resources

**Real-world example from the code:**
```dart
// Line 358-360: Bug report submission fails silently
try {
  await _db.submitReport(userId, category, description);
} catch (_) {
  // Silently ignore — user sees success regardless
}
```

Users think their bug report was submitted, but it may have failed completely. This erodes trust and prevents valuable feedback from reaching developers.

**The fix:** Every error should be logged with context, and users should see appropriate feedback. Non-critical errors can still show success to users, but must be logged for monitoring.

### 2. Which issue has the highest real-world impact?

**Lack of Complete Data Deletion (Right to Erasure)**

Under PDPA/GDPR, users have the legal right to have their personal data completely erased. The current implementation has critical gaps:

**Current problems:**
1. Bug reports remain in Firestore with userId after account deletion
2. Local Hive data (favorites, view counts) not cleared on account deletion
3. No confirmation of what data will be deleted
4. No data export before deletion
5. No audit trail of deletion operations

**Real-world impact:**
- **Legal Liability**: PDPA violations can result in fines up to 5 million THB or 2% of annual revenue
- **Regulatory Action**: Data Protection Board can order app suspension
- **User Trust**: Users increasingly care about privacy; incomplete deletion damages reputation
- **Business Risk**: Cannot expand to EU markets without GDPR compliance

**Why this ranks highest:**
Unlike technical bugs that affect individual users, privacy violations affect EVERY user and have legal consequences. A single complaint to the PDPA board could require immediate app shutdown until compliance is achieved.

**The solution requires:**
1. Complete data inventory and deletion workflow
2. Legal review of privacy policy
3. Regular compliance audits
4. User-facing transparency about data handling

### 3. If this app goes to production, what could go wrong?

**Scenario 1: Firebase Costs Spiral Out of Control (Most Likely)**
- **What happens**: Without rate limiting, API key restrictions, or abuse prevention, malicious actors could spam the Firebase API
- **Impact**: Thousands of dollars in unexpected Firebase bills, potential service shutdown
- **Prevention**: Implement Firebase App Check, add API key restrictions, set billing alerts

**Scenario 2: Data Breach via Browser Extension (High Impact)**
- **What happens**: Malicious browser extension reads unencrypted user emails from localStorage
- **Impact**: Mass email harvesting, phishing attacks targeting users, reputational damage
- **Prevention**: Encrypt all PII in local storage, add security headers, educate users

**Scenario 3: PDPA Complaint Forces Shutdown (Legal Risk)**
- **What happens**: Single user complains to Thai Data Protection Board about incomplete data deletion
- **Impact**: Formal investigation, potential fine, mandatory app suspension until compliance
- **Prevention**: Implement complete Right to Erasure, add privacy policy, get legal review

**Scenario 4: Silent Errors Cause Data Inconsistency (Gradual Degradation)**
- **What happens**: Silent Firestore failures cause profiles to desync, username claims leak, favorites disappear
- **Impact**: User frustration, support burden, difficulty diagnosing issues, users abandon app
- **Prevention**: Implement comprehensive logging, error monitoring, data consistency checks

**Scenario 5: Account Deletion Race Condition Leaves Orphaned Data (Data Pollution)**
- **What happens**: Network failure during deletion leaves Firestore profile but deletes auth account
- **Impact**: Orphaned personal data in database, PDPA violation (data kept after deletion request)
- **Prevention**: Reverse deletion order (auth first), implement cleanup job, add compensating transactions

**Scenario 6: XSS Attack via Bug Report Submission (Security Breach)**
- **What happens**: Attacker submits malicious JavaScript in bug report, admin views it in Firebase Console
- **Impact**: Admin account compromise, potential database access
- **Prevention**: Sanitize all user inputs, add CSP headers, implement admin UI with proper output encoding

**Most Critical Path Forward:**
1. Add comprehensive error logging immediately (foundation for all debugging)
2. Implement complete data deletion (legal compliance)
3. Add Firebase security restrictions (cost and abuse protection)
4. Encrypt local PII (privacy protection)
5. Add monitoring and alerting (operational awareness)

---

## Submission Checklist

- [x] Completed Lab Sheet (this file)
- [ ] Code improvements implemented
- [ ] Security hardening applied
- [ ] Privacy features added
- [ ] Documentation updated
- [x] Minimum 3 Code issues identified (5 found)
- [x] Minimum 3 Security issues identified (5 found)
- [x] Minimum 3 Privacy issues identified (9 found)

---

## Implementation Notes

This lab sheet provides a comprehensive analysis of the RenaArt codebase. The proposed solutions are practical and prioritized based on:
- Legal compliance requirements (PDPA)
- Security risk level
- User impact
- Implementation complexity

Each section includes specific file references and line numbers to make implementation straightforward. The solutions balance security/privacy best practices with the reality of a student project's resources and timeline.
