# RenaArt 🏛️

**The Digital Museum of the Renaissance**  
A Pinterest-style Flutter mobile app for exploring Renaissance artworks.

---

## Screenshots Overview

| Home | Search | Collection | Profile |
|------|--------|------------|---------|
| Masonry feed with period filters | Filter by artist, period, medium | Liked + Offline library | Stats + Settings |

---

## Tech Stack

| Concern | Package |
|---------|---------|
| State Management | `flutter_riverpod ^2.4.9` |
| Navigation | `go_router ^13.2.0` |
| Masonry Grid | `flutter_staggered_grid_view ^0.7.0` |
| Image Caching | `cached_network_image ^3.3.1` |
| Loading Shimmer | `shimmer ^3.0.0` |
| Local Storage | `hive + hive_flutter` |
| Preferences | `shared_preferences` |
| HTTP | `dio ^5.4.0` |

---

## Architecture

Feature-based folder structure:

```
lib/
├── core/
│   ├── constants/      # AppConstants, AppStrings
│   ├── router/         # GoRouter setup with RouteNames enum
│   └── theme/          # AppTheme (light + dark), AppColors
├── features/
│   ├── auth/screen/    # SplashScreen, LoginScreen, RegisterScreen
│   ├── home/
│   │   ├── screen/     # HomeScreen, MainShell
│   │   ├── widgets/    # ArtworkCard (core reusable component)
│   │   └── providers/  # All Riverpod providers
│   ├── search/screen/  # SearchScreen with filter panel
│   ├── artwork_detail/ # ArtworkDetailScreen
│   ├── collection/     # CollectionScreen (favorites + offline tabs)
│   └── profile/        # ProfileScreen
├── models/
│   ├── artwork_model.dart   # Hive entity
│   ├── user_model.dart
│   └── mock_data.dart       # 12 real Renaissance artworks
└── main.dart
```

---

## Features

### 🏠 Home
- SliverAppBar with floating/snap behavior
- Period filter chips (All, Early Renaissance, High Renaissance, etc.)
- MasonryGridView 2-column Pinterest-style feed
- "SUGGESTED FOR YOU" section

### 🔍 Search
- Real-time search across title, artist, period, medium
- Collapsible filter panel with:
  - Creator chips (popular Renaissance artists)
  - Period chips
  - Medium chips
- Active filter count indicator
- Clear all filters button

### 📁 Collection
- Tab: **Liked** — all favorited artworks
- Tab: **Offline Library** — saved artworks with storage bar (x/10)
- Long press to remove from offline
- Empty states with illustrations

### 👤 Profile
- No profile picture — shows initial letter only (by design)
- Editable **Nickname** (freely)
- Editable **Username** (shows email confirmation note)
- High Fidelity Mode toggle
- Dark/Light Mode toggle
- Stats: Liked, Offline, Viewed counts
- Sign out, Report, Help sections

### 🎨 Artwork Detail
- Hero image with SliverAppBar
- Like & Save Offline action buttons
- Period tag, artist name, year, dimensions, medium
- Historical Background section
- Meaning & Symbols section
- Key symbol chips
- "More to Explore" horizontal scroll of related artworks
- Offline full warning snackbar (max 10)

---

## Design System

**Palette (Light):** Parchment `#F5F0E8` · Sienna `#8B3A2A` · Gold `#C49A3C` · Ink `#1A1208`

**Palette (Dark):** Deep Black `#0F0B07` · Dark Card `#221A10` · Gold Light `#D4AF5A`

**Typography:**
- Headlines: **Cormorant** (serif, italic)  
- Body/UI: **Jost** (geometric sans)

**Aesthetic:** Modern museum minimal — clean, airy, luxurious without decoration overload.

---

## Setup

```bash
# 1. Get packages
flutter pub get

# 2. Generate Hive adapters (already pre-generated)
flutter packages pub run build_runner build

# 3. Run
flutter run
```

> **Note:** Currently uses mock data (12 real Renaissance artworks via Wikipedia images). The app is designed to connect to the Met Museum API in production — just swap `MockData` calls with `MetApiService` calls in the providers.

---

## Mock Data

12 artworks included:
- Mona Lisa (da Vinci)
- The Birth of Venus (Botticelli)  
- The School of Athens (Raphael)
- David (Michelangelo)
- Primavera (Botticelli)
- The Creation of Adam (Michelangelo)
- The Last Supper (da Vinci)
- Portrait of a Young Woman (Petrus Christus)
- Pietà (Michelangelo)
- The Arnolfini Portrait (Jan van Eyck)
- The Sistine Madonna (Raphael)
- Venus of Urbino (Titian)

---

## Student Info

| Field | Value |
|-------|-------|
| Student Name | Jutatip Sriputhon |
| Student ID | 6631503124 |
| App Name | RenaArt |
| Course | Mobile Application Development |
