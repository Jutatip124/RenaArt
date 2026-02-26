# RenaArt 🏛️

**The Digital Museum of the Renaissance**

> Mobile Application Development — Mini Project  
> Student: Jutatip Sriputhon | ID: 6631503124  
> GitHub: https://github.com/Jutatip124/RenaArt.git

---

## Tech Stack

| Layer | Technology | Week Reference |
|-------|-----------|---------------|
| Framework | Flutter | Week 4 |
| State Management | Riverpod | Week 3 (Global vs Local State) |
| Navigation | GoRouter | Week 4 |
| Backend API | Met Museum REST API | Week 3 Part 3 |
| Local Storage | Hive + SharedPreferences | Week 3 Data Model |
| Image Loading | CachedNetworkImage | Week 3 (1080p cap) |
| Grid Layout | flutter_staggered_grid_view | Week 3 (Masonry) |
| Connectivity | connectivity_plus | Week 3 (Offline Strategy) |

---

## Architecture (Week 4: Feature-based folder structure)

```
lib/
├── core/
│   ├── constants/     app_constants.dart   ← API URLs, Hive box names
│   ├── router/        app_router.dart      ← GoRouter setup
│   └── theme/         app_theme.dart       ← Parchment/Sienna/Gold palette
│
├── features/
│   ├── auth/screen/   splash, login, register
│   ├── home/
│   │   ├── screen/    home_screen.dart, main_shell.dart
│   │   ├── widgets/   artwork_card.dart   ← Atomic Design: Molecule
│   │   └── providers/ app_providers.dart  ← All Riverpod providers
│   ├── search/        search_screen.dart
│   ├── artwork_detail/ artwork_detail_screen.dart
│   ├── collection/    collection_screen.dart
│   └── profile/       profile_screen.dart
│
├── models/
│   ├── artwork_model.dart    ← Week 3: API_RESPONSE + UserArtworkState + OfflineArtwork
│   └── user_model.dart       ← Week 3: USER_PROFILE spec
│
├── services/
│   ├── met_api_service.dart       ← Week 3: 3 API endpoints
│   └── local_storage_service.dart ← Week 3: Hive/SharedPreferences
│
└── main.dart
```

---

## Week 3: Data Model Compliance

### API_RESPONSE.json Entity
Fields: `objectID`, `title`, `artistDisplayName`, `artistId`, `objectDate`,  
`period`, `medium`, `dimensions`, `repository`, `primaryImage`,  
`primaryImageSmall`, `description`, `historicalContext`, `meaning`,  
`keySymbols`, `relatedArtworkIds`, `department`, `isPublicDomain`

### USER_ARTWORK_STATE.json (Hive typeId=1)
Fields: `artworkId`, `userId`, `isFavorited`, `favoritedDate`, `lastViewed`, `viewCount`, `notes`

### OFFLINE_ARTWORK.json (Hive typeId=2)
Fields: `artworkId`, `deviceId`, `isOfflineAvailable`, `downloadedDate`,  
`localImagePath`, `originalFileSizeMB`, `resizedFileSizeMB`, `imageResolution`, `lastAccessDate`

### USER_PROFILE (SharedPreferences + Hive)
Fields: `userId`, `name`, `nickname`, `username`, `email`, `createdAt`,  
`preferences` { darkMode, highFidelityMode, offlineLimit(10), preferredPeriods },  
`stats` { totalFavorites, artworksViewed, totalSaveToReturns, offlineSaved }

---

## Week 3: API Endpoints

| Action | Method | Endpoint | Returns |
|--------|--------|----------|---------|
| Search IDs | GET | `/search?q=...&hasImages=true` | `{total, objectIDs}` |
| Get Artwork | GET | `/objects/{id}` | Full artwork JSON |
| Download Image | GET | `{primaryImage URL}` | Binary JPEG/PNG |
| Save Favorite | LOCAL | `Hive.put(UserArtworkState)` | Success/failure |
| Get Favorites | LOCAL | `Hive.query(isFavorited=true)` | List |
| Save Offline | LOCAL | `Hive.put(OfflineArtwork)` | `{localPath, fileSizeMB}` |

---

## Week 3: State Management

### Global State (Riverpod — needed across all screens)
- `favoritesProvider` — User's saved/favorited artwork IDs
- `offlineIdsProvider` — Which artworks are saved offline
- `authProvider` — Current user session
- `themeModeProvider` — Light/dark theme
- `isOnlineProvider` — Connectivity status

### Local State (screen-specific)
- `searchQueryProvider` — Search text
- `searchArtistFilterProvider` / `searchPeriodFilterProvider` / `searchMediumFilterProvider`
- `selectedPeriodProvider` — Home feed period filter

---

## Week 3: Offline Strategy
- Show cached artworks from Hive with **"Viewing offline content"** banner
- Disable live search and API fetching when offline
- Display offline badge on saved artworks
- Max 10 artworks saved offline (Week 2 feasibility spec)
- Image resolution capped at 1080p

---

## Setup

```bash
# 1. Clone repo
git clone https://github.com/Jutatip124/RenaArt.git
cd RenaArt

# 2. Add fonts to assets/fonts/
#    Cormorant-Regular.ttf, Cormorant-Italic.ttf, Cormorant-SemiBold.ttf, Cormorant-Bold.ttf
#    Jost-Regular.ttf, Jost-Medium.ttf, Jost-Light.ttf
#    → Download from: fonts.google.com

# 3. Get packages
flutter pub get

# 4. Run
flutter run
```

---

## Design System (Week 5: Parchment/Sienna/Gold palette)

| Token | Light | Dark |
|-------|-------|------|
| Background | `#F5F0E8` Parchment | `#0F0B07` Deep black |
| Primary | `#8B3A2A` Sienna | `#A84E3A` Sienna Light |
| Accent | `#C49A3C` Gold | `#D4AF5A` Gold Light |
| Text | `#1A1208` Ink Dark | `#F0E8D8` Warm white |
| Headline font | Cormorant (serif italic) | — |
| Body font | Jost (geometric sans) | — |

---

*Week 2 App Concept · Week 3 Architecture · Week 4 Scaffolding · Week 5 UI Prototype*
