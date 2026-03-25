# RenaArt — The Digital Museum of the Renaissance

A Flutter web application that curates 300 Renaissance artworks (c. 1300–1600) with detailed historical backgrounds, meanings, and symbolism. Built with Firebase Authentication, Cloud Firestore, and deployed on Firebase Hosting.

**Live App:** https://renaart-ded29.web.app

---

## Project Description

RenaArt helps users explore Renaissance art in a beginner-friendly way. The app features:

- **300 curated artworks** — Paintings, sculptures, frescoes, drawings, and prints by 16 major Renaissance masters (Leonardo da Vinci, Michelangelo, Raphael, Botticelli, Titian, Dürer, Caravaggio, and more)
- **Detailed artwork pages** — Historical background, meaning & symbolism, key symbols, and related artworks ("More to Explore")
- **Search with autocomplete** — Filter by artist, title, art form, subject, period, and region
- **Firebase Authentication** — Email/password login, Google Sign-In, guest mode, password reset, account deletion
- **Per-user favorites** — Each user has their own collection, scoped by Firebase Auth UID
- **Offline access** — Save up to 10 artworks locally via Hive for viewing without internet
- **Fullscreen image viewer** — Pinch-to-zoom for artwork details
- **Dark / Light mode** — Dark mode default with modern Art Gallery aesthetic
- **High Fidelity mode** — Toggle full-resolution images for bandwidth-conscious users
- **Report an Issue** — In-app bug reporting with 7 categories + optional Object ID

### Tech Stack

| Technology | Purpose |
|---|---|
| Flutter (≥3.3.0) | Cross-platform UI framework |
| Dart (≥3.3.0) | Programming language |
| Cloud Firestore | Artwork database (300 docs), user profiles, usernames |
| Firebase Auth | Email/password + Google Sign-In |
| Firebase Hosting | Web deployment with CDN |
| Riverpod | State management |
| GoRouter | Declarative navigation with auth guards |
| Hive | Local storage (favorites, offline, cache) |
| Dio | HTTP client |

---

## Setup Instructions

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.3.0
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- A Firebase project (or use the existing `renaart-ded29`)

### 1. Clone the Repository

```bash
git clone https://github.com/Jutatip124/RenaArt.git
cd RenaArt
```

### 2. Install Dependencies

```bash
cd renaart
flutter pub get
```

### 3. Firebase Configuration

The app is pre-configured for the `renaart-ded29` Firebase project. The configuration file is at:

```
renaart/lib/firebase_options.dart
```

**Firebase services used:**

| Service | Details |
|---|---|
| **Firebase Hosting** | Deploys to `https://renaart-ded29.web.app` |
| **Cloud Firestore** | Region: `asia-southeast3`. Collections: `artworks` (300 docs), `users`, `usernames`, `reports` |
| **Firebase Auth** | Providers: Email/Password, Google Sign-In |

**Firestore Security Rules** are defined in `firestore.rules`:
- `artworks` — Public read, no client write
- `users` — Owner read/write only (auth.uid == userId)
- `usernames` — Public read, authenticated create/delete
- `reports` — Authenticated create only

**To use your own Firebase project:**

1. Create a new Firebase project at https://console.firebase.google.com
2. Enable **Authentication** (Email/Password + Google providers)
3. Create a **Cloud Firestore** database
4. Run FlutterFire CLI to generate config:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=your-project-id
   ```
5. Deploy Firestore rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

---

## How to Run the App

### Run Locally (Web)

```bash
cd renaart
flutter run -d chrome
```

### Build for Production

```bash
cd renaart
flutter build web --release
```

The build output is in `renaart/build/web/`.

### Deploy to Firebase Hosting

```bash
# From the repo root
firebase deploy --only hosting
```

**Deploy output:**
```
✔  Deploy complete!
Hosting URL: https://renaart-ded29.web.app
```

---

## Firebase Configuration Notes

### `firebase.json`

```json
{
  "hosting": {
    "public": "renaart/build/web",
    "rewrites": [{ "source": "**", "destination": "/index.html" }],
    "headers": [{
      "source": "**/*.@(js|html|css|json)",
      "headers": [{ "key": "Cache-Control", "value": "no-cache, no-store, must-revalidate" }]
    }]
  },
  "firestore": { "rules": "firestore.rules" }
}
```

- **SPA Rewrite:** All routes fall through to `index.html` (required for GoRouter)
- **Cache-Control:** `no-cache` headers prevent stale service worker issues after deploys

### Firestore Collections

| Collection | Documents | Key Fields |
|---|---|---|
| `artworks` | 300 | title, artist, year, medium, description, meaning, keySymbols, imageUrl, artForm, subject, period, region |
| `users` | Dynamic | userId, name, nickname, username, email, createdAt, darkMode, highFidelity |
| `usernames` | Dynamic | userId (for uniqueness enforcement) |
| `reports` | Dynamic | userId, category, description, objectId (optional), createdAt |

### Authentication Providers

| Provider | Status |
|---|---|
| Email/Password | ✅ Enabled |
| Google Sign-In | ✅ Enabled |

### Important Notes

- **After deploying**, users may need to hard-refresh (`Ctrl+Shift+R`) to clear the service worker cache
- **Dark mode** is the default theme for new users
- **Favorites are per-user** — stored locally with composite key `userId_artworkId`
- **Offline artworks** are limited to 10 (Hive local storage)
- **Email field is locked** in the profile screen — users cannot change their email after registration

---

## Project Structure

```
RenaArt/
├── firebase.json              # Firebase Hosting + Firestore config
├── firestore.rules            # Firestore security rules
├── PRD-RenaArt.md             # Product Requirements Document
├── RenaArt.md                 # Original project submission/evaluation
├── README.md                  # This file
├── scripts/                   # Dev utilities (data generation, Firestore upload)
└── renaart/                   # Flutter project
    ├── pubspec.yaml
    ├── web/                   # Web assets (index.html, icons, manifest)
    ├── assets/
    │   ├── data/              # Bundled JSON (local fallback)
    │   ├── fonts/             # Cormorant + Jost font files
    │   └── images/            # App logo
    └── lib/
        ├── main.dart          # Entry point
        ├── firebase_options.dart
        ├── core/              # Constants, router, theme
        ├── features/          # Auth, home, search, detail, collection, profile, landing
        ├── models/            # Artwork, User data classes
        └── services/          # Firestore, local storage, artwork API router
```

---

## Security & Privacy

### Security Measures

RenaArt implements multiple security layers to protect user data:

- **Firebase Authentication** - Industry-standard user authentication
- **Firestore Security Rules** - Server-side access control enforcement
- **Security Headers** - XSS, clickjacking, and MIME-sniffing protection
- **Input Validation** - Client-side validation for all user inputs
- **API Key Restrictions** - Firebase API keys restricted to authorized domains only

**Important:** Before deploying to production, please review [SECURITY.md](SECURITY.md) for complete security configuration checklist.

### Privacy & PDPA Compliance

RenaArt respects user privacy and complies with Thailand's Personal Data Protection Act (PDPA):

**Data Collection:**
- Email address (authentication only)
- Username and nickname (user identity)
- Artwork interactions (favorites, view counts)
- User preferences (theme, display settings)

**User Rights:**
- ✅ Right to Access - Export your data anytime
- ✅ Right to Erasure - Complete account deletion
- ✅ Right to Rectification - Update your information
- ✅ Right to Data Portability - JSON data export

**Data Protection:**
- No data sold to third parties
- Minimal data collection principle
- Secure storage with Firebase encryption
- Local data encryption recommended for production

For detailed privacy information, see [WEEK_7-8-9_LAB_SHEET.md](WEEK_7-8-9_LAB_SHEET.md).

### Security Configuration Checklist

Before production deployment:

- [ ] Enable Firebase API key restrictions in Firebase Console
- [ ] Enable Firebase App Check for abuse prevention
- [ ] Review and test Firestore Security Rules
- [ ] Configure billing alerts in Google Cloud Console
- [ ] Enable Firebase Crashlytics for error monitoring
- [ ] Implement local data encryption for sensitive fields
- [ ] Review and update privacy policy
- [ ] Test data export and deletion features
- [ ] Perform security testing (input validation, XSS, etc.)

---

## Development Best Practices

### Code Quality

The codebase follows these quality standards:

- **Error Handling:** Centralized logging via `LoggingService`
- **Input Validation:** Dedicated `ValidationService` for all user inputs
- **Privacy:** `PrivacyService` for PDPA compliance features
- **Security:** Security headers configured in `firebase.json`

### Testing

```bash
# Run tests
cd renaart
flutter test

# Run with coverage
flutter test --coverage
```

### Troubleshooting

**Common Issues:**

1. **Firebase initialization error**
   - Check `firebase_options.dart` configuration
   - Ensure Firebase project is accessible
   - Verify API key restrictions don't block localhost

2. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Check Flutter version: `flutter --version`
   - Verify all dependencies are compatible

3. **Local storage errors (Hive)**
   - Clear browser IndexedDB via DevTools
   - Check browser privacy settings (IndexedDB must be enabled)

---

## Credits

- **Student ID:** 6631503124
- **Course:** Mobile Application Development
- **Artwork images:** Public domain via Wikimedia Commons
- **Fonts:** [Cormorant](https://fonts.google.com/specimen/Cormorant) (serif), [Jost](https://fonts.google.com/specimen/Jost) (sans-serif)
