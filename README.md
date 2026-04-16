# RenaArt — The Digital Museum of the Renaissance

RenaArt is a Flutter app focused on Renaissance artworks with **local-first content** and **Firebase-backed user data**.

- **Live App:** https://renaart-ded29.web.app
- **Landing Page:** https://renaart-ded29.web.app/#/landing
- **Privacy Policy:** https://renaart-ded29.web.app/privacy-policy
- **Delete Account:** https://renaart-ded29.web.app/delete-account

---

## Current Project State

- Artwork metadata is stored in `renaart/assets/data/artworks.json`
- Full-size artwork images are bundled in `renaart/assets/images/artworks/` (**300 files**, ~76.51 MB total)
- Lightweight thumbnails are bundled in `renaart/assets/images/artworks/thumbs/` (**300 files**, ~7.75 MB total)
- Home/Search/Detail rendering uses local assets (`Image.asset`) for artwork images
- User/account features remain on Firebase (auth, favorites cloud sync, reports, profile)
- Local storage uses Hive + SharedPreferences for cache/offline/preferences

---

## Data Source Rules

### Artwork data (Local)
- `AppConstants.activeSource = ApiSource.localAsset`
- JSON path: `assets/data/artworks.json`
- Full image path format: `assets/images/artworks/local_XXX.jpg`
- Thumbnail path format: `assets/images/artworks/thumbs/local_XXX.jpg`

### User data (Firebase)
- Firebase Auth: login/register/Google/guest flow
- Firestore:
  - `users/{uid}`
  - `users/{uid}/favorites/{artworkId}`
  - `usernames/{username}`
  - `reports/{reportId}`

> `artworks` collection is no longer the runtime source for UI content in normal mode.

---

## Features

- Curated Renaissance feed + detail view
- Search and filters (artist, period, medium, subject, region)
- Per-user favorites with cloud sync
- Offline save (limit 10 artworks)
- Dark/Light mode
- Privacy consent flow + account deletion flow

---

## Performance Notes (Web)

- All 300 local artwork images have been optimized for web delivery
- Grid/list surfaces (Home/Search/Auth mosaic) use thumbnail paths to reduce initial payload and decode memory
- Gallery/detail/mosaic widgets use lower decode settings (`cacheWidth`, low filter quality)
- App image cache is constrained (`main.dart`): 60 entries / 25 MB to reduce browser memory pressure and unexpected reloads

If images fail to show after updates, run:

```bash
cd renaart
flutter clean
flutter pub get
flutter run -d chrome
```

Then hard refresh browser (`Ctrl+Shift+R`).

---

## Setup

### Prerequisites

- Flutter SDK
- Firebase CLI (`npm install -g firebase-tools`)

### Install & Run

```bash
git clone https://github.com/Jutatip124/RenaArt.git
cd RenaArt/renaart
flutter pub get
flutter run -d chrome
```

---

## Deploy

Deploy from repo root:

```bash
cd RenaArt
firebase deploy --only hosting
```

Root `firebase.json` predeploy handles Flutter web build.

---

## Repository Layout

```text
RenaArt/
├── firebase.json
├── firestore.rules
├── README.md
├── PRD-RenaArt.md
├── scripts/
└── renaart/
    ├── assets/
    │   ├── data/artworks.json
    │   └── images/
    │       └── artworks/
    │           ├── local_*.jpg
    │           └── thumbs/local_*.jpg
    ├── lib/
    ├── web/
    └── pubspec.yaml
```
