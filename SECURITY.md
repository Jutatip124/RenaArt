# Security Policy

## Reporting Security Issues

If you discover a security vulnerability in RenaArt, please report it responsibly:

**Email:** [Your security contact email]
**Response Time:** We aim to respond within 48 hours

Please **DO NOT** open public GitHub issues for security vulnerabilities.

## Security Measures

### Authentication & Authorization
- Firebase Authentication for secure user management
- Firestore Security Rules enforce data access control
- Password requirements: minimum 6 characters
- Re-authentication required for sensitive operations (email, password, username changes, account deletion)

### Data Protection
- **Local Storage:** User data stored locally should be encrypted (see recommendations below)
- **Firebase Security:** API keys restricted by domain in Firebase Console
- **Firestore Rules:** Read/write access controlled per collection based on authentication state

### Security Headers
The following security headers are configured in Firebase Hosting:
- `X-Content-Type-Options: nosniff` - Prevent MIME type sniffing
- `X-Frame-Options: DENY` - Prevent clickjacking
- `X-XSS-Protection: 1; mode=block` - Enable XSS filtering
- `Referrer-Policy: strict-origin-when-cross-origin` - Control referrer information
- `Permissions-Policy` - Disable unnecessary browser features

### Input Validation
- Email validation using regex patterns
- Username validation: alphanumeric and underscore only, 3-20 characters
- Password strength checking
- User input sanitization for bug reports
- PII detection in user-submitted text

## Security Best Practices for Deployment

### Before Production Deployment:

1. **Firebase Security Configuration**
   ```bash
   # In Firebase Console:
   # 1. Go to Project Settings > General
   # 2. Under "Your apps" > Web app
   # 3. Click "Manage API keys"
   # 4. Add HTTP referrer restrictions:
   #    - your-domain.com/*
   #    - localhost:* (for development only)
   ```

2. **Enable Firebase App Check** (Recommended)
   - Protects against abuse and unauthorized API usage
   - Required for production apps
   - Set up in Firebase Console > App Check

3. **Review Firestore Security Rules**
   ```bash
   # Test rules locally:
   firebase emulators:start --only firestore

   # Deploy rules:
   firebase deploy --only firestore:rules
   ```

4. **Enable Logging & Monitoring**
   - Set up Firebase Crashlytics for error tracking
   - Configure Firebase Performance Monitoring
   - Review Firebase Console regularly for unusual activity

5. **Set Billing Alerts**
   - Configure budget alerts in Google Cloud Console
   - Set up daily spending limits
   - Monitor Firebase usage dashboard

### Secure Local Development:

1. **Never commit secrets**
   ```bash
   # Add to .gitignore:
   .env
   .env.local
   firebase-debug.log
   ```

2. **Use environment variables for sensitive config**
   ```bash
   # Run with environment variables:
   flutter run --dart-define=API_KEY=your_key
   ```

3. **Keep dependencies updated**
   ```bash
   flutter pub upgrade
   flutter pub outdated
   ```

## Known Limitations

### Web Platform Security Constraints:
- **Local Storage Encryption:** Browser localStorage and IndexedDB cannot be fully encrypted on web platform
  - **Mitigation:** Use Web Crypto API for sensitive data encryption
  - **Recommendation:** Implement `flutter_secure_storage` when targeting mobile platforms

- **API Key Exposure:** Firebase Web API keys are public by design
  - **Mitigation:** Enforce domain restrictions in Firebase Console
  - **Mitigation:** Enable Firebase App Check for additional protection

- **Client-Side Validation:** All client-side validation can be bypassed
  - **Mitigation:** Firestore Security Rules provide server-side enforcement
  - **Recommendation:** Never trust client input

## Security Checklist

### Pre-Production Security Review:
- [ ] Firebase API keys restricted to authorized domains only
- [ ] Firebase App Check enabled and configured
- [ ] Firestore Security Rules reviewed and tested
- [ ] All sensitive operations require re-authentication
- [ ] Input validation implemented for all user inputs
- [ ] Error messages don't leak sensitive information
- [ ] Security headers configured in hosting
- [ ] Billing alerts configured
- [ ] Monitoring and logging enabled
- [ ] Dependencies updated to latest versions
- [ ] Security testing performed (manual + automated)
- [ ] Privacy policy reviewed by legal counsel
- [ ] PDPA/GDPR compliance verified

### Ongoing Security Maintenance:
- [ ] Monthly dependency updates
- [ ] Quarterly security rule review
- [ ] Regular monitoring of Firebase Console for anomalies
- [ ] Review and rotate credentials annually
- [ ] Test incident response procedures
- [ ] Monitor security advisories for Flutter/Firebase

## Threat Model

### Assumptions:
1. Firebase services (Auth, Firestore) are trusted and secure
2. HTTPS encryption protects data in transit
3. Firestore Security Rules are the authoritative security boundary
4. Browser storage is semi-trusted (accessible to extensions/XSS)

### Threats In Scope:
- Unauthorized access to user accounts
- Unauthorized access to other users' data
- Data breaches via compromised browsers
- API abuse and resource exhaustion
- Input injection attacks (XSS, etc.)
- Privacy violations (data leakage, tracking)

### Threats Out of Scope:
- Physical device theft (mobile platform concern)
- Nation-state level attacks
- Zero-day vulnerabilities in Flutter/Firebase
- Social engineering attacks on users
- DDoS attacks on Firebase infrastructure

## Incident Response Plan

If a security incident is detected:

1. **Immediate Actions:**
   - Disable compromised features via Firebase Remote Config
   - Rotate affected credentials
   - Document incident timeline and impact

2. **Investigation:**
   - Review Firebase Audit Logs
   - Analyze attack vectors
   - Identify affected users

3. **Remediation:**
   - Deploy security patches
   - Force password resets if credentials compromised
   - Update security rules if bypassed

4. **Communication:**
   - Notify affected users within 72 hours (PDPA requirement)
   - Provide clear guidance on protective actions
   - Report to Data Protection Board if required

5. **Post-Incident:**
   - Conduct root cause analysis
   - Update security controls
   - Document lessons learned

## Security Dependencies

### Critical Security Components:
- `firebase_auth` - User authentication
- `cloud_firestore` - Data storage with security rules
- `hive` - Local data persistence (consider encryption addon)
- `shared_preferences` - User preferences storage

### Recommended Additions:
- `flutter_secure_storage` - Encrypted local storage (mobile platforms)
- `encrypt` - Encryption utilities for sensitive data
- `firebase_app_check` - API abuse prevention

## Contact

For security questions or concerns, please contact:
- Security Team: [Your contact]
- PDPA Compliance: [Your DPO contact]

Last Updated: 2026-03-25
