# PRD — RenaArt
**Product Requirements Document**
**Version:** 2.0
**Date:** March 14, 2026
**Status:** Approved

---

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Target User](#3-target-user)
4. [Goals & Success Metrics](#4-goals--success-metrics)
5. [Core Features (MVP)](#5-core-features-mvp)
6. [User Stories](#6-user-stories)
7. [User Journey](#7-user-journey)
8. [App Architecture](#8-app-architecture)
9. [Technical Stack](#9-technical-stack)
10. [Screen Inventory & Navigation](#10-screen-inventory--navigation)
11. [Data Model](#11-data-model)
12. [Data Source & Firestore](#12-data-source--firestore)
13. [Authentication](#13-authentication)
14. [Offline Support](#14-offline-support)
15. [UI / Design Principles](#15-ui--design-principles)
16. [Deployment](#16-deployment)
17. [Out of Scope](#17-out-of-scope)
18. [Risks & Mitigations](#18-risks--mitigations)
19. [Appendix](#19-appendix)

---

## 1. Executive Summary

**App Name:** RenaArt
**Category:** Education
**Pitch:** A mobile app that helps users explore Renaissance artworks with clear explanations, search tools, and offline access.

RenaArt is a Flutter-based web application that curates 300 artworks exclusively from the Renaissance period (c. 1300–1600), stored in **Cloud Firestore** for fast, reliable access. The app features real **Firebase Authentication** (email/password and Google Sign-In), per-user favorites and offline collections, and a modern Art Gallery UI with dark/light theme support.

The artwork dataset includes paintings, sculptures, frescoes, drawings, and prints by 16 major Renaissance artists — each with detailed historical background, meaning, symbolism, and provenance.

**Live URL:** https://renaart-ded29.web.app

---

## 2. Problem Statement

### 2.1 Pain Point
Finding clear and engaging information about Renaissance art is difficult because content is scattered across multiple websites. Most sources provide long text with low engagement and require constant internet access, which limits learning while traveling.

### 2.2 Why Existing Solutions Fall Short

| Solution | Limitation |
|---|---|
| Google Arts & Culture | Information-rich but not focused or beginner-friendly |
| Wikipedia | Text-heavy; lacks structured, guided explanations |
| Instagram / Pinterest | Visually appealing but lacks historical context and meaning |

---

## 3. Target User

### Primary Persona
| Attribute | Detail |
|---|---|
| **Age** | 20–25 |
| **Occupation** | University student |
| **Location** | Chiang Rai, Thailand |
| **Tech Skill Level** | Normal (comfortable with smartphones) |
| **Daily Problem** | Interested in art but finds online information scattered, difficult to understand, and inconvenient when internet access is poor |

### User Need Summary
She enjoys viewing famous artworks but often feels confused because the information is spread across many sources, written in an academic style that takes too much time to understand. She needs a focused, beginner-friendly app that works even in areas with limited connectivity.

---

## 4. Goals & Success Metrics

### Product Goals
| Goal | Description |
|---|---|
| Discoverability | Users can explore and search Renaissance artworks with minimal effort |
| Comprehension | Artwork pages deliver clear, structured explanations of history and meaning |
| Accessibility | Core content is available offline after initial save |
| Engagement | Users build and revisit their personal collection |
| Personalization | Per-user favorites and collections via Firebase Auth |

### Success Metrics (KPIs)
| Metric | Target |
|---|---|
| Artwork detail page views per session | ≥ 3 |
| Artworks saved to collection per active user | ≥ 5 |
| Offline collection access rate | ≥ 30% of sessions |
| Search-to-detail conversion | ≥ 60% |
| App crash rate (web) | < 1% |

---

## 5. Core Features (MVP)

| # | Feature | What It Does | Why It Matters |
|---|---|---|---|
| F1 | **Artwork Browsing** | Displays a curated feed of 300 Renaissance artworks from Cloud Firestore with category chips (For You, periods, art forms, subjects) | Core function to explore content |
| F2 | **Search & Filters** | Find artworks by title, artist, medium, period, subject, or region with autocomplete suggestions | Easy navigation for specific interests |
| F3 | **Artwork Detail Page** | Shows artwork image, title, artist, year, medium, dimensions, historical background, meaning & symbols, key symbols, and related artworks ("More to Explore") | Provides deeper understanding and context |
| F4 | **Fullscreen Image Viewer** | Pinch-to-zoom, pan, and view artwork in immersive fullscreen mode | Appreciate visual details |
| F5 | **Favorite & Save (My Collection)** | Save artworks locally via Hive for offline access; favorites scoped per user ID | Creates a personal, persistent collection |
| F6 | **Offline Access** | View saved artworks (max 10) without an internet connection | Solves the connectivity pain point |
| F7 | **Firebase Authentication** | Email/password login, Google Sign-In, guest mode, password reset, account deletion | Enables personalized, secure experience |
| F8 | **User Profile** | Display name (editable), username (editable with re-auth), email (locked), password change, User ID (read-only), delete account | Full account management |
| F9 | **Report an Issue** | Submit bug reports with 7 categories + optional Object ID to Firestore | User feedback collection |
| F10 | **Dark / Light Theme** | Dark mode by default with user toggle; adaptive UI across all screens | Improves accessibility and personal preference |
| F11 | **High Fidelity Mode** | Toggle full-resolution artwork images; settings persist to Firestore | Bandwidth-conscious image quality control |
| F12 | **Help & FAQ** | In-app FAQ dialog with 7 common questions and answers | Self-service user support |

---

## 6. User Stories

### Authentication
- As a new user, I want to register with my email, nickname, and username so that I can create a personal account.
- As a returning user, I want to log in with email/password or Google Sign-In so that my saved collection persists.
- As a user, I want to continue as a guest so that I can explore without creating an account.
- As a user, I want to reset my password via email so that I can recover my account.
- As a user, I want to delete my account permanently so that all my data is removed.

### Browsing & Discovery
- As a user, I want to see a curated home feed of Renaissance artworks with period filter chips so that I can browse by era.
- As a user, I want to search by artwork title, artist name, or keyword with autocomplete so that I can find specific works quickly.
- As a user, I want to filter by art form, subject, and region so that I can narrow down results.
- As a user, I want to see a shimmer loading state while artworks load so that the experience feels smooth.

### Artwork Detail
- As a user, I want to tap an artwork card to see its full detail page including historical background, meaning & symbols, and related artworks so that I can understand it in context.
- As a user, I want to view the artwork in fullscreen with pinch-to-zoom so that I can appreciate the visual details.
- As a user, I want to see "More to Explore" related artworks (same artist, period, or medium) so that I can continue browsing.

### Collection & Offline
- As a user, I want to save an artwork to My Collection so that I can revisit it later.
- As a user, I want to view my saved artworks offline (max 10) so that I can learn while traveling without internet.
- As a user, I want to remove an artwork from My Collection so that I can keep it organized.
- As a user, I want my favorites to be scoped to my account so that different users have separate collections.

### Profile
- As a user, I want to see my profile with account info and collection stats.
- As a user, I want to edit my display name and username (with re-authentication).
- As a user, I want to change my password with strength indicators.
- As a user, I want to toggle dark/light mode so that I can use the app comfortably.
- As a user, I want to report issues via the app so that problems can be tracked.
- As a user, I want to log out so that my session is cleared securely.

---

## 7. User Journey

```
1. Open App
   └── Splash Screen (logo animation, auto-redirect)
       ├── [Not logged in] → Login Screen
       │   ├── Sign In with Email/Password
       │   ├── Sign In with Google
       │   ├── Continue as Guest
       │   ├── Forgot Password → Reset email sent
       │   └── Create Account → Register Screen
       │       ├── Nickname, Username (availability check), Email, Password (strength indicators)
       │       └── Register → Home Screen
       └── [Logged in / persistent session] → Home Screen

2. Home Feed
   └── Browse 300 Renaissance artworks (staggered grid)
       ├── Category chips: For You | Early Renaissance | High Renaissance | Northern Renaissance | Mannerism | Painting | Sculpture | Fresco | Religious | Portrait | Mythology
       └── Tap artwork card → Artwork Detail Screen
           ├── Historical Background, Meaning & Symbols
           ├── Tap ♥ Like → Added to favorites (per-user)
           ├── Tap Save Offline → Stored locally (max 10)
           ├── Tap image → Fullscreen viewer (pinch-to-zoom)
           └── More to Explore → Related artworks

3. Search
   └── Enter artist, artwork, or keyword (autocomplete suggestions)
       ├── Filter by Art Form, Subject, Region
       └── Filtered results → Tap → Artwork Detail Screen

4. My Collection
   ├── Favorites tab → All liked artworks
   └── Offline tab → Downloaded artworks (max 10)
       └── Tap → Artwork Detail Screen (from local storage)

5. Profile
   ├── Account Info: Display Name, Username, Email (locked), User ID
   ├── Change Password (with strength indicators)
   ├── Toggle Dark/Light mode, High Fidelity mode
   ├── Help & FAQ
   ├── About RenaArt (version, GitHub link)
   ├── Report an Issue (7 categories + optional Object ID)
   ├── Delete Account (with re-authentication)
   └── Sign Out → Back to Login Screen
```

---

## 8. App Architecture

RenaArt follows a **feature-first layered architecture** with Riverpod for reactive state management.

```
lib/
├── main.dart                          # Entry point: Firebase.initializeApp, Hive init, ProviderScope
├── firebase_options.dart              # FlutterFire CLI config (web)
├── core/
│   ├── constants/app_constants.dart   # Data source config, Hive box names, filter lists
│   ├── router/app_router.dart         # GoRouter with auth-guard redirects
│   └── theme/app_theme.dart           # Light & dark theme (Modern Art Gallery aesthetic)
├── features/
│   ├── auth/
│   │   ├── screen/splash_screen.dart  # Logo animation, auto-redirect
│   │   ├── screen/login_screen.dart   # Email/password, Google, guest, forgot password
│   │   ├── screen/register_screen.dart # Nickname, username check, password strength
│   │   └── widgets/art_mosaic_bg.dart # Decorative background
│   ├── landing/
│   │   └── screen/landing_screen.dart # Public intro page with Get Started CTA
│   ├── home/
│   │   ├── screen/home_screen.dart    # Staggered grid feed with category chips
│   │   ├── screen/main_shell.dart     # Bottom navigation (4 tabs, icon-only)
│   │   ├── providers/app_providers.dart # ALL providers: auth, favorites, offline, feed, search
│   │   └── widgets/artwork_card.dart  # Reusable artwork card with heart/save buttons
│   ├── search/screen/search_screen.dart
│   ├── artwork_detail/
│   │   ├── screen/artwork_detail_screen.dart # Detail + More to Explore
│   │   └── screen/image_viewer_screen.dart   # Fullscreen pinch-to-zoom
│   ├── collection/screen/collection_screen.dart  # Favorites + Offline with counts
│   └── profile/screen/profile_screen.dart  # Account, settings, Help & FAQ, report
├── models/
│   ├── artwork_model.dart             # Hive-annotated: Artwork, UserArtworkState, OfflineArtwork
│   └── user_model.dart                # UserModel with darkMode + highFidelity fields
└── services/
    ├── firestore_artwork_service.dart # Primary: Cloud Firestore artworks collection
    ├── firestore_user_service.dart    # User profiles, usernames, reports
    ├── artwork_api_service.dart       # Router: Firestore → local asset fallback
    ├── local_artwork_service.dart     # Fallback: bundled JSON (assets/data/)
    └── local_storage_service.dart     # Hive boxes: cache, favorites (per-user), offline
```

### State Management Pattern
- **Riverpod 2 (`flutter_riverpod`)** — all state in `Provider` / `FutureProvider` / `StateNotifierProvider`
- `ProviderScope` wraps the entire widget tree at `main.dart`
- `authProvider` (StateNotifierProvider) — Firebase Auth state, drives router redirects
- `favoritesProvider` — per-user favorites, auto-reads userId from authProvider
- `offlineIdsProvider` — offline save state (max 10)
- `homeFeedProvider` — derived provider: raw feed + period filter (no API re-fetch on filter change)

---

## 9. Technical Stack

| Layer | Technology | Version |
|---|---|---|
| **Framework** | Flutter | SDK ≥3.3.0 |
| **Language** | Dart | ≥3.3.0 |
| **State Management** | flutter_riverpod | ^2.4.9 |
| **Navigation** | go_router | ^13.2.0 |
| **Backend** | Firebase (Core + Auth + Firestore) | ^4.5.0 / ^6.2.0 / ^6.1.3 |
| **HTTP Client** | dio | ^5.4.0 |
| **Local Storage** | hive + hive_flutter | ^2.2.3 / ^1.1.0 |
| **Preferences** | shared_preferences | ^2.2.2 |
| **Network Status** | connectivity_plus | ^6.0.3 |
| **Image Caching** | cached_network_image | ^3.3.1 |
| **UI — Grid** | flutter_staggered_grid_view | ^0.7.0 |
| **UI — Skeleton** | shimmer | ^3.0.0 |
| **Fonts** | Cormorant (serif), Jost (sans-serif) | (bundled assets) |
| **Hosting** | Firebase Hosting | — |
| **Database** | Cloud Firestore (asia-southeast3) | — |
| **Auth** | Firebase Authentication | Email/Password + Google |
| **Data Source** | Cloud Firestore `artworks` collection (300 docs) | — |

---

## 10. Screen Inventory & Navigation

### Screens

| Screen | Route | Description |
|---|---|---|
| SplashScreen | `/` | Logo animation, auto-redirects based on auth state |
| LandingScreen | `/landing` | Public intro page — feature highlights and Get Started CTA |
| LoginScreen | `/login` | Email/password + Google Sign-In + guest + forgot password |
| RegisterScreen | `/register` | Nickname, username (availability check), email, password (strength) |
| HomeScreen | `/home` (tab 0) | Staggered artwork feed with category filter chips |
| SearchScreen | `/home` (tab 1) | Keyword search with autocomplete, art form / subject / region filters |
| CollectionScreen | `/home` (tab 2) | Favorites + Offline tabs (with counts in tab labels) |
| ProfileScreen | `/home` (tab 3) | Account info, password change, theme/HiFi toggle, Help & FAQ, Report, delete |
| ArtworkDetailScreen | `/artwork/:id` | Full detail: image, metadata, history, meaning, symbols, related |
| ImageViewerScreen | `/artwork/:id/image` | Fullscreen pinch-to-zoom image viewer |

### Navigation Structure
- **Bottom Navigation (MainShell):** Home → Search → Collection → Profile
- **Auth Guard:** Unauthenticated users redirected to `/login`; authenticated users on `/login` or `/register` redirected to `/home`
- **Deep Link:** `/artwork/:id` accepts optional preloaded `Artwork` via `extra` for instant display

---

## 11. Data Model

### `Artwork` (Hive TypeId: 0 / Firestore `artworks` collection)
| Field | Type | Description |
|---|---|---|
| `id` | `String` | Unique artwork identifier |
| `title` | `String` | Artwork title |
| `artist` | `String` | Artist display name |
| `year` | `String` | Date or period string |
| `medium` | `String` | Materials and technique (e.g., "Oil on panel") |
| `dimensions` | `String` | Physical dimensions |
| `location` | `String` | Current museum/gallery location |
| `imageUrl` | `String` | Public domain image URL (Wikimedia Commons) |
| `description` | `String` | Historical background (detailed paragraph) |
| `meaning` | `String` | Meaning & symbolism explanation |
| `keySymbols` | `List<String>` | Key symbols in the artwork |
| `artForm` | `String` | Classification: Painting, Sculpture, Fresco, Drawing, Print |
| `subject` | `String` | Subject: Religious, Portrait, Mythology, Allegory, Historical |
| `period` | `String` | Period: Early Renaissance, High Renaissance, Northern Renaissance, Mannerism |
| `region` | `String` | Origin: Florence, Rome, Venice, Milan, Germany, Flanders |

### `UserArtworkState` (Hive TypeId: 1 — per-user favorites)
| Field | Type | Description |
|---|---|---|
| `artworkId` | `String` | Artwork ID |
| `userId` | `String` | User ID (composite key: `userId_artworkId`) |
| `isFavorited` | `bool` | Favorite flag |
| `favoritedDate` | `String?` | ISO 8601 timestamp |
| `viewCount` | `int` | Number of times viewed |
| `lastViewed` | `String?` | Last viewed timestamp |

### `OfflineArtwork` (Hive TypeId: 2 — max 10)
| Field | Type | Description |
|---|---|---|
| `artworkId` | `String` | Artwork ID |
| `isOfflineAvailable` | `bool` | Offline flag |
| `downloadedDate` | `String` | Download timestamp |
| `imageResolution` | `String` | Resolution hint |
| `lastAccessDate` | `String` | Last access timestamp |

### `UserModel` (SharedPreferences + Firestore `users` collection)
| Field | Type | Description |
|---|---|---|
| `userId` | `String` | Firebase Auth UID |
| `name` | `String` | Display name |
| `nickname` | `String` | Nickname |
| `username` | `String` | Unique username (alphanumeric + underscore, 3+ chars) |
| `email` | `String` | Registered email (locked, cannot change) |
| `createdAt` | `String` | Account creation timestamp |
| `isGuest` | `bool` | Guest mode flag |
| `darkMode` | `bool` | Dark/light theme preference (persisted to Firestore) |
| `highFidelity` | `bool` | Full-resolution image mode (persisted to Firestore) |

---

## 12. Data Source & Firestore

### Cloud Firestore
- **Project:** `renaart-ded29`
- **Region:** `asia-southeast3`
- **Collections:**

| Collection | Documents | Description |
|---|---|---|
| `artworks` | 300 | Complete Renaissance artwork dataset with full metadata |
| `users` | Dynamic | User profiles (keyed by Firebase Auth UID) |
| `usernames` | Dynamic | Username uniqueness registry (case-insensitive) |
| `reports` | Dynamic | User-submitted issue reports (category, description, optional Object ID) |

### Firestore Security Rules
```
artworks  → public read, no client write
users     → owner read/write only (auth.uid == userId)
usernames → public read, authenticated create/delete (own records only)
reports   → authenticated create only, no read
```

### Data Flow
1. **Primary:** Cloud Firestore `artworks` collection (300 documents, pre-populated)
2. **Fallback:** Bundled local JSON asset (`assets/data/artworks.json`) if Firestore unavailable
3. **Cache:** Hive `artworks_cache` box stores fetched artworks for offline access

### Artwork Dataset
- **Scope:** Renaissance period, c. 1300–1600
- **Types:** Painting, Sculpture, Fresco, Drawing, Print
- **Artists:** 16 major Renaissance masters including Leonardo da Vinci, Michelangelo, Raphael, Botticelli, Titian, Dürer, Caravaggio, Jan van Eyck, El Greco, Donatello, and more
- **Images:** Public domain URLs from Wikimedia Commons
- **Content:** Each artwork includes detailed historical background, meaning & symbolism, key symbols list

---

## 13. Authentication

### Firebase Authentication
- **Providers:** Email/Password, Google Sign-In
- **Guest Mode:** Local-only session without Firebase Auth (limited features)

### Auth Flow
| Method | Implementation |
|---|---|
| **Email/Password** | `signInWithEmailAndPassword` / `createUserWithEmailAndPassword` |
| **Google Sign-In** | `signInWithPopup(GoogleAuthProvider())` |
| **Password Reset** | `sendPasswordResetEmail` — sends real reset link to email |
| **Session Persistence** | Firebase Auth persistent session + SharedPreferences backup |
| **Re-authentication** | Required for username change, password change, account deletion |
| **Account Deletion** | Deletes Firestore profile, releases username, deletes Firebase Auth account |

### Username System
- Unique usernames stored in Firestore `usernames` collection
- Availability check with debounced Firestore query during registration
- Case-insensitive uniqueness enforcement

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special character

---

## 14. Offline Support

| Scenario | Behaviour |
|---|---|
| No internet on launch | App loads from Hive cache; My Collection fully available |
| Artwork saved while online | Full metadata stored in Hive box (max 10 offline artworks) |
| Search with no internet | Graceful error state with retry prompt |
| Artwork detail from Collection | Loaded from Hive; no network request needed |
| Storage full (10/10) | "Storage Full" message; user must remove one first |

Connectivity is monitored via `connectivity_plus`. The UI reflects real-time online/offline status with a banner.

---

## 15. UI / Design Principles

| Principle | Implementation |
|---|---|
| **Modern Art Gallery Aesthetic** | Matte black (dark) / near-white (light) backgrounds; museum-quality feel |
| **Typography** | Cormorant (serif) for titles, headings, and branding; Jost (sans-serif) for body text and UI |
| **Logo** | Renaissance sculpture silhouette — white in dark mode, black in light mode |
| **Color Palette** | Dark: `#0E0E0E` bg, `#1A1A1A` surface, `#C8A84B` gold accent. Light: `#F6F6F6` bg, `#FFFFFF` surface, `#111111` text |
| **Immersive Imagery** | Full-bleed artwork images, gradient overlays, glass-style back buttons |
| **Beginner-Friendly** | Short, plain-language descriptions; structured content with headers |
| **Dark Mode Default** | First-time users see dark mode; toggle available in Profile |
| **Success Notifications** | Theme-matching SnackBars with green checkmark icon, white text |
| **Error Handling** | Friendly error messages; no technical jargon shown to users |
| **Performance** | `cached_network_image` with shimmer placeholders; staggered grid layout |
| **Accessibility** | Sufficient contrast ratios; locked email field prevents accidental changes |

---

## 16. Deployment

### Firebase Hosting

The Flutter web build is deployed to **Firebase Hosting** with global CDN, HTTPS, and SPA routing.

**Live URL:** https://renaart-ded29.web.app

### Firebase Configuration (`firebase.json`)
```json
{
  "hosting": {
    "public": "renaart/build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{ "source": "**", "destination": "/index.html" }],
    "headers": [{
      "source": "**/*.@(js|html|css|json)",
      "headers": [{ "key": "Cache-Control", "value": "no-cache, no-store, must-revalidate" }]
    }]
  },
  "firestore": { "rules": "firestore.rules" }
}
```

### Build & Deploy
```bash
# 1. Build Flutter web
cd renaart
flutter build web --release

# 2. Copy build output and deploy
cd ..
cp -r renaart/build/web/* build/
firebase deploy --only hosting
```

### Firebase Services Used
| Service | Purpose |
|---|---|
| **Firebase Hosting** | Web app hosting with CDN |
| **Cloud Firestore** | Artwork database (300 docs), user profiles, usernames, reports |
| **Firebase Authentication** | Email/password + Google Sign-In |

---

## 17. Out of Scope

The following items are explicitly **not** included in the MVP:

| Item | Reason |
|---|---|
| Paid / premium features | Scope kept to free features only (per submission evaluation) |
| Audio narration / guided tours | Complexity beyond MVP timeline |
| User-generated content / reviews | Content moderation required |
| Push notifications | Not required for core learning loop |
| iOS / Android native release | Web-only deployment via Firebase Hosting |
| Social sharing | Beyond MVP feature set |
| Multi-language support (i18n) | Single language (English) for MVP |

---

## 18. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Firestore quota exceeded | Low | High | Bundled local JSON fallback; Hive caching reduces reads |
| Image URLs break (Wikimedia) | Low | Medium | `cached_network_image` with error placeholder; retry mechanism |
| Large image payloads degrade performance | Medium | Medium | Images loaded on demand; shimmer placeholders; cached locally |
| Firebase Auth state loss on web | Medium | Medium | Persistent Firebase session + SharedPreferences backup; defensive `_load()` with try-catch |
| Stale browser cache after deploy | Medium | Low | `Cache-Control: no-cache` headers; users can Ctrl+Shift+R |
| Google Sign-In COOP issues | Low | Medium | Using `signInWithPopup`; fallback error handling |
| Hive/IndexedDB corrupted | Low | Medium | `_openBoxSafe` clears corrupted data and retries; try-catch around all Hive operations |

---

## 19. Appendix

### A. Evaluation Summary (Original Submission)
| Criterion | Score |
|---|---|
| Completeness | 100 / 100 |
| Clarity | 100 / 100 |
| Feasibility | 95 / 100 |
| **Final Result** | ✅ Pass |

**Feasibility deduction (-5):** Section 8.1 mentions "free users", implying potential paid features. Recommendation: Clarify or keep scope to free features only.

### B. App Feature-to-Pain-Point Mapping
| Pain Point | App Feature | Outcome |
|---|---|---|
| Art feels difficult to understand | Clear, structured artwork explanations with meaning & symbols | Users understand artworks more easily |
| Information is scattered across sites | One curated app with 300 Renaissance artworks | Users save time |
| Long academic text is hard to read | Structured content with headers, short paragraphs, symbol chips | Learning feels simpler |
| No internet access while traveling | Offline save via Hive local storage (max 10) | Users can learn anywhere |
| Can't personalize experience | Firebase Auth with per-user favorites and collections | Each user has their own space |

### C. Glossary
| Term | Definition |
|---|---|
| **Cloud Firestore** | Google's serverless NoSQL document database for real-time data syncing |
| **Firebase Auth** | Google's authentication service supporting email/password, Google Sign-In, and more |
| **Firebase Hosting** | Google's static and dynamic web hosting service with global CDN |
| **Hive** | A lightweight, NoSQL Flutter/Dart key-value database for local persistence |
| **Riverpod** | A reactive state management library for Flutter |
| **GoRouter** | A declarative URL-based routing package for Flutter |
| **SPA (Single-Page Application)** | A web app where all routing is handled client-side; requires server-side rewrite rules to serve `index.html` for all paths |
| **Wikimedia Commons** | A media repository of free-use images, used as the source for public domain artwork images |
