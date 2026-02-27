# PRD — RenaArt
**Product Requirements Document**
**Version:** 1.0
**Date:** February 27, 2026
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
12. [External Integrations](#12-external-integrations)
13. [Offline Support](#13-offline-support)
14. [UI / Design Principles](#14-ui--design-principles)
15. [Firebase Deployment](#15-firebase-deployment)
16. [Out of Scope](#16-out-of-scope)
17. [Risks & Mitigations](#17-risks--mitigations)
18. [Appendix](#18-appendix)

---

## 1. Executive Summary

**App Name:** RenaArt
**Category:** Education
**Pitch:** A mobile app that helps users explore Renaissance artworks with clear explanations, search tools, and offline access.

RenaArt is a Flutter-based cross-platform application (mobile + web) that curates artwork exclusively from the Renaissance period, sourced in real-time from the Metropolitan Museum of Art (Met Museum) public API. The app aims to lower the barrier to art appreciation for students and enthusiasts by presenting structured, beginner-friendly content in a single, cohesive experience — with the ability to save artworks locally for offline viewing.

The web version is deployed and hosted on **Firebase Hosting**, making it accessible on any device via browser without installation.

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

### Success Metrics (KPIs)
| Metric | Target |
|---|---|
| Artwork detail page views per session | ≥ 3 |
| Artworks saved to collection per active user | ≥ 5 |
| Offline collection access rate | ≥ 30% of sessions |
| Search-to-detail conversion | ≥ 60% |
| App crash rate (web + mobile) | < 1% |

---

## 5. Core Features (MVP)

| # | Feature | What It Does | Why It Matters |
|---|---|---|---|
| F1 | **Artwork Browsing** | Displays a curated feed of Renaissance artworks from the Met Museum API | Core function to explore content |
| F2 | **Search & Filters** | Find artworks or artists by keyword | Easy navigation for specific interests |
| F3 | **Artwork Detail Page** | Shows the artwork image, title, artist, year, medium, dimensions, and historical explanation | Provides deeper understanding and context |
| F4 | **Favorite & Save (My Collection)** | Save artworks locally via Hive for offline access | Creates a personal, persistent collection |
| F5 | **Offline Access** | View saved artworks without an internet connection | Solves the connectivity pain point |
| F6 | **Authentication** | Email-based login and registration with local session persistence | Enables personalized, stateful experience |
| F7 | **Dark / Light Theme** | System-aware UI theme toggle | Improves accessibility and personal preference |

---

## 6. User Stories

### Authentication
- As a new user, I want to register with my email so that I can create a personal account.
- As a returning user, I want to log in so that my saved collection persists across sessions.

### Browsing & Discovery
- As a user, I want to see a curated home feed of Renaissance artworks so that I can start exploring immediately.
- As a user, I want to search by artwork title or artist name so that I can find specific works quickly.
- As a user, I want to see a shimmer loading state while artworks load so that the experience feels smooth.

### Artwork Detail
- As a user, I want to tap an artwork card to see its full detail page including history, medium, and artist biography so that I can understand it in context.
- As a user, I want to see a high-quality image of the artwork so that I can appreciate the visual details.

### Collection & Offline
- As a user, I want to save an artwork to My Collection so that I can revisit it later.
- As a user, I want to view my saved artworks offline so that I can learn while traveling without internet.
- As a user, I want to remove an artwork from My Collection so that I can keep it organized.

### Profile
- As a user, I want to see my profile with the number of saved artworks so that I know my collection size.
- As a user, I want to toggle dark/light mode so that I can use the app comfortably in any environment.
- As a user, I want to log out so that my session is cleared securely.

---

## 7. User Journey

```
1. Open App
   └── Splash Screen (auto-redirect)
       ├── [Not logged in] → Login Screen
       │   └── Register Screen (new users)
       └── [Logged in] → Home Screen

2. Home Feed
   └── Browse curated Renaissance artworks (staggered grid)
       └── Tap artwork card → Artwork Detail Screen
           ├── Read explanation, history, artist info
           └── Tap ♥ Save → Artwork added to My Collection

3. Search
   └── Enter artist or artwork name
       └── Filtered results → Tap → Artwork Detail Screen

4. My Collection
   └── View all saved artworks (offline-accessible)
       └── Tap → Artwork Detail Screen (from local storage)

5. Profile
   └── View username and collection count
       ├── Toggle dark/light theme
       └── Log out → Back to Login Screen
```

---

## 8. App Architecture

RenaArt follows a **feature-first layered architecture** with Riverpod for reactive state management.

```
lib/
├── main.dart                   # App entry point, Hive init, ProviderScope
├── core/
│   ├── constants/              # API base URLs, app-wide constants
│   ├── router/                 # GoRouter config with auth-guard redirects
│   └── theme/                  # Light & dark MaterialTheme definitions
├── features/
│   ├── auth/                   # Splash, Login, Register screens
│   ├── home/                   # Feed screen, MainShell (bottom nav), providers
│   ├── search/                 # Search screen
│   ├── artwork_detail/         # Detail screen
│   ├── collection/             # My Collection screen
│   └── profile/                # Profile screen
├── models/
│   ├── artwork_model.dart      # Hive-annotated Artwork data class
│   └── user_model.dart         # User session model
└── services/
    ├── met_api_service.dart    # Met Museum REST API client (Dio)
    ├── local_storage_service.  # Hive box management
    └── mock_artwork_service.dart # Fallback mock data
```

### State Management Pattern
- **Riverpod 2 (`flutter_riverpod`)** — all state is held in `Provider` / `FutureProvider` / `StateNotifierProvider` instances
- `ProviderScope` wraps the entire widget tree at `main.dart`
- `authProvider` drives the router's auth-guard redirect logic

---

## 9. Technical Stack

| Layer | Technology | Version |
|---|---|---|
| **Framework** | Flutter | SDK ≥3.3.0 |
| **Language** | Dart | ≥3.3.0 |
| **State Management** | flutter_riverpod | ^2.4.9 |
| **Navigation** | go_router | ^13.2.0 |
| **HTTP Client** | dio | ^5.4.0 |
| **Local Storage** | hive + hive_flutter | ^2.2.3 / ^1.1.0 |
| **Preferences** | shared_preferences | ^2.2.2 |
| **Network Status** | connectivity_plus | ^6.0.3 |
| **Image Caching** | cached_network_image | ^3.3.1 |
| **UI — Grid** | flutter_staggered_grid_view | ^0.7.0 |
| **UI — Skeleton** | shimmer | ^3.0.0 |
| **Fonts** | Cormorant, Jost | (bundled assets) |
| **CI / Hosting** | Firebase Hosting | — |
| **Data Source** | Met Museum Open API | v1 (public domain) |

---

## 10. Screen Inventory & Navigation

### Screens

| Screen | Route | Description |
|---|---|---|
| SplashScreen | `/` | Auto-redirects based on auth state |
| LoginScreen | `/login` | Email + password login |
| RegisterScreen | `/register` | New user registration |
| HomeScreen | `/home` (tab 0) | Staggered artwork feed |
| SearchScreen | `/home` (tab 1) | Keyword search |
| CollectionScreen | `/home` (tab 2) | Saved artworks |
| ProfileScreen | `/home` (tab 3) | User info, theme toggle, logout |
| ArtworkDetailScreen | `/artwork/:id` | Full artwork detail |

### Navigation Structure
- **Bottom Navigation (MainShell):** Home → Search → Collection → Profile
- **Auth Guard:** Unauthenticated users are always redirected to `/login`
- **Deep Link:** `/artwork/:id` accepts an optional preloaded `Artwork` object via `extra` for instant display before API response

---

## 11. Data Model

### `Artwork` (Hive Box)
| Field | Type | Description |
|---|---|---|
| `objectId` | `int` | Met Museum object ID (primary key) |
| `title` | `String` | Artwork title |
| `artistName` | `String` | Artist display name |
| `artistBio` | `String?` | Artist biography |
| `objectDate` | `String?` | Date / period string |
| `medium` | `String?` | Materials and technique |
| `dimensions` | `String?` | Physical dimensions |
| `primaryImageUrl` | `String` | CDN URL of full image |
| `smallImageUrl` | `String?` | CDN URL of thumbnail |
| `department` | `String?` | Museum department |
| `culture` | `String?` | Cultural attribution |
| `isPublicDomain` | `bool` | Only `true` artworks are used |
| `isFavorited` | `bool` | Local save flag |

### `User` (SharedPreferences / session)
| Field | Type | Description |
|---|---|---|
| `uid` | `String` | Local unique identifier |
| `email` | `String` | Registered email |
| `displayName` | `String?` | Display name |

---

## 12. External Integrations

### Met Museum Open Access API
- **Base URL:** `https://collectionapi.metmuseum.org/public/collection/v1`
- **Endpoints Used:**
  - `GET /search?q={query}&hasImages=true&departmentId=11` — returns `{total, objectIDs[]}`
  - `GET /objects/{id}` — returns full artwork JSON
- **Department 11** corresponds to European Paintings (Renaissance focus)
- **Security:** Custom Dio interceptor validates all image URLs originate from `*.metmuseum.org`
- **Public Domain Only:** The app only surfaces artworks where `isPublicDomain == true`
- **Timeouts:** Connect 10 s / Receive 15 s

---

## 13. Offline Support

| Scenario | Behaviour |
|---|---|
| No internet on launch | App loads from Hive; My Collection fully available |
| Artwork saved while online | Image URL + metadata stored in Hive box |
| Search with no internet | Graceful error state with retry prompt |
| Artwork detail from Collection | Loaded from Hive; no network request needed |

Connectivity is monitored via `connectivity_plus`. The UI reflects real-time online/offline status.

---

## 14. UI / Design Principles

| Principle | Implementation |
|---|---|
| **Renaissance Aesthetic** | Cormorant (serif) for artwork titles and headings; Jost (sans-serif) for body text |
| **Immersive Imagery** | Full-bleed artwork images with minimal chrome |
| **Beginner-Friendly** | Short, plain-language descriptions; avoid academic jargon |
| **Adaptive Theme** | System-aware dark/light mode; user can override in Profile |
| **Performance** | `cached_network_image` for CDN-cached artwork photos; shimmer placeholders during load |
| **Accessibility** | Sufficient contrast ratios in both themes; no text baked into images |

---

## 15. Firebase Deployment

### Overview
The Flutter web build is deployed to **Firebase Hosting**, providing a globally distributed CDN, HTTPS by default, and SPA routing support.

### Firebase Hosting Configuration (`firebase.json`)
```json
{
  "hosting": {
    "public": "renaart/build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

- **`public`:** Points to Flutter's web build output directory `renaart/build/web`
- **`rewrites`:** All routes fall through to `index.html` — required for Flutter's single-page app routing with GoRouter

### Deployment Steps

#### Prerequisites
```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Authenticate
firebase login
```

#### Build & Deploy
```bash
# 1. Navigate to the Flutter project
cd renaart

# 2. Build Flutter web (release mode)
flutter build web --release --no-wasm-dry-run

# 3. Return to repo root and deploy
cd ..
firebase deploy --only hosting
```

#### Deploy Output
Upon success, Firebase CLI outputs:
```
✔  Deploy complete!

Hosting URL: https://<your-project-id>.web.app
```

### Environment Targets

| Target | Description |
|---|---|
| **Production** | `firebase deploy --only hosting` — deploys to default Firebase Hosting site |
| **Preview Channel** | `firebase hosting:channel:deploy preview` — temporary preview URL for QA |

### CI / CD (Recommended)

Add the following GitHub Actions workflow for automated deploys on push to `main`:

```yaml
# .github/workflows/firebase-deploy.yml
name: Deploy to Firebase Hosting

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - name: Install dependencies
        run: cd renaart && flutter pub get
      - name: Build web
        run: cd renaart && flutter build web --release --no-wasm-dry-run
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
```

---

## 16. Out of Scope

The following items are explicitly **not** included in the MVP:

| Item | Reason |
|---|---|
| Paid / premium features | Scope kept to free features only (per submission evaluation) |
| Audio narration / guided tours | Complexity beyond MVP timeline |
| User-generated content / reviews | Content moderation required |
| Push notifications | Not required for core learning loop |
| iOS / Android app store release | MVP targets web (Firebase Hosting) + local Flutter run |
| Social sharing | Beyond MVP feature set |
| Multi-language support (i18n) | Single language (English) for MVP |

---

## 17. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Met Museum API rate limits or downtime | Medium | High | Implement mock artwork service as fallback; cache responses in Hive |
| Large image payloads degrade performance | Medium | Medium | Use `smallImageUrl` in cards; `primaryImageUrl` only on detail screen; `cached_network_image` |
| Offline data stale / artwork removed from API | Low | Medium | Store full artwork snapshot at save time; show "archived" badge if no longer available online |
| Firebase Hosting build deployment failure | Low | Medium | Keep build output committed or use CI artifact; test `firebase serve` locally before deploying |
| Authentication state loss on web | Medium | Medium | Persist session in `shared_preferences`; re-check on app resume |

---

## 18. Appendix

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
| Art feels difficult to understand | Clear, structured artwork explanations | Users understand artworks more easily |
| Information is scattered across sites | One curated app for Renaissance art | Users save time |
| Long academic text is hard to read | Structured content with headers and short paragraphs | Learning feels simpler |
| No internet access while traveling | Offline save via Hive local storage | Users can learn anywhere |

### C. Glossary
| Term | Definition |
|---|---|
| **Met Museum API** | The Metropolitan Museum of Art's free, public REST API providing metadata and images for 470,000+ artworks |
| **Hive** | A lightweight, NoSQL Flutter/Dart key-value database for local persistence |
| **Riverpod** | A reactive state management library for Flutter |
| **GoRouter** | A declarative URL-based routing package for Flutter |
| **CanvasKit** | Flutter's Skia-based web renderer providing high-fidelity graphics at the cost of a larger initial load |
| **Firebase Hosting** | Google's static and dynamic web hosting service with global CDN |
| **SPA (Single-Page Application)** | A web app where all routing is handled client-side; requires server-side rewrite rules to serve `index.html` for all paths |
