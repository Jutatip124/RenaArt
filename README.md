# RenaArt — The Digital Museum of the Renaissance

Flutter web app for exploring Renaissance artworks with authentication, per-user favorites, offline saving, and PDPA-aligned privacy consent.

- **Live App:** https://renaart-ded29.web.app
- **Landing Page:** https://renaart-ded29.web.app/#/landing
- **Privacy Policy:** https://renaart-ded29.web.app/privacy-policy
- **Delete Account:** https://renaart-ded29.web.app/delete-account

---

## Current Feature Overview

- Curated Renaissance artwork browsing and detail pages
- Search + filtering (artist, period, medium, subject, region)
- Firebase Auth: Email/Password, Google Sign-In, Guest mode
- Per-user favorites with cloud sync (`users/{uid}/favorites`)
- Offline save limit: 10 artworks (Hive local storage)
- Dark/Light mode + High Fidelity image toggle
- In-app report issue flow (`reports` collection)
- Account deletion flow with re-authentication
- Responsive app grids (Home/Search/Collection): desktop auto-shows more cards, mobile stays 2-column

---

## Privacy & Account Behavior (Current)

- **Privacy consent dialog** is shown **only on first Login/Register attempt**.
- Consent is stored locally in SharedPreferences (`privacy_policy_accepted`).
- Guest mode does not require consent dialog.
- Splash screen no longer blocks on privacy consent.
- Account deletion removes:
  - Firebase Auth account
  - User profile document (`users/{uid}`)
  - Favorites subcollection (`users/{uid}/favorites`)
  - User reports (`reports` where `userId == uid`)
  - Username reservation in `usernames`

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter / Dart | App framework |
| Riverpod | State management |
| GoRouter | Navigation + auth redirects |
| Firebase Auth | Authentication |
| Cloud Firestore | User/account/favorites/reports data |
| Hive + SharedPreferences | Local cache, favorites, offline, settings |
| Firebase Hosting | Web deployment |

---

## Data Source Strategy

Artwork loading is resilient and not tied to a single backend path:

1. Home/Search read from local cache first (Hive).
2. If cache is empty, app loads bundled local JSON assets.
3. If needed, it can fall back via `ArtworkApiService` (Firestore/local by `AppConstants.activeSource`).

---

## Firestore Structure

| Path | Purpose |
|---|---|
| `artworks` | Artwork dataset (used by Firestore source mode) |
| `users/{uid}` | User profile/preferences |
| `users/{uid}/favorites/{artworkId}` | Per-user favorites |
| `usernames/{username}` | Username uniqueness mapping |
| `reports/{reportId}` | User-submitted issue reports |

`firestore.rules` currently enforce:
- `artworks`: public read, no client write
- `users` + `users/{uid}/favorites`: owner-only read/write
- `usernames`: public read, authenticated claim/release
- `reports`: authenticated create only

---

## Setup

### Prerequisites

- Flutter SDK
- Firebase CLI (`npm install -g firebase-tools`)

### Install

```bash
git clone https://github.com/Jutatip124/RenaArt.git
cd RenaArt
cd renaart
flutter pub get
```

### Run (Web)

```bash
flutter run -d chrome
```

---

## Build & Deploy

Deploy uses root `firebase.json` predeploy hooks, so build runs automatically.

```bash
cd RenaArt
firebase deploy --only hosting
```

Important:
- Deploy from **repo root** (project root), not `renaart/`.
- Root `firebase.json` contains Hosting rewrites.
- `renaart/firebase.json` is FlutterFire metadata and does not define hosting targets.
- `predeploy` runs:
  - `flutter pub get`
  - `flutter build web --release`
  - copy `privacy-policy.html` and `delete-account.html` into `build/web`

---

## Firebase Hosting Config (Root)

```json
{
  "hosting": {
    "predeploy": [
      "cd renaart && flutter pub get && flutter build web --release",
      "cp renaart/web/privacy-policy.html renaart/build/web/privacy-policy.html",
      "cp renaart/web/delete-account.html renaart/build/web/delete-account.html"
    ],
    "public": "renaart/build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      { "source": "/delete-account", "destination": "/delete-account.html" },
      { "source": "/delete-account/**", "destination": "/delete-account.html" },
      { "source": "/privacy-policy", "destination": "/privacy-policy.html" },
      { "source": "/privacy-policy/**", "destination": "/privacy-policy.html" },
      { "source": "**", "destination": "/index.html" }
    ],
    "headers": [
      {
        "source": "**/*.@(js|html|css|json)",
        "headers": [{ "key": "Cache-Control", "value": "no-cache, no-store, must-revalidate" }]
      }
    ]
  }
}
```

---

## Repository Structure

```text
RenaArt/
├── firebase.json
├── firestore.rules
├── README.md
├── PRD-RenaArt.md
├── RenaArt.md
├── scripts/
└── renaart/
    ├── lib/
    ├── assets/
    ├── web/
    │   ├── privacy-policy.html
    │   └── delete-account.html
    └── pubspec.yaml
```

---

## Credits

- Student ID: 6631503124
- Course: Mobile Application Development
- Artwork source: Wikimedia Commons / bundled dataset
