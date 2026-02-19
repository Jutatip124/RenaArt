# RenaArt 🎨
**The Digital Museum of the Renaissance**

A Flutter mobile app that lets users explore Renaissance artworks (via the free Met Museum API) with a Pinterest-style masonry feed, search & filters, favorites, and offline saving.

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── router/
│   │   ├── app_router.dart            # GoRouter + Bottom Nav shell
│   │   └── route_names.dart           # Route constants
│   └── theme/
│       └── app_theme.dart             # Colors, fonts, theme
├── models/
│   ├── artwork.dart                   # Artwork data model (Hive)
│   └── artwork.g.dart                 # Generated Hive adapter
├── services/
│   ├── met_museum_service.dart        # Met Museum REST API
│   ├── storage_service.dart           # Hive local storage
│   └── providers.dart                 # Riverpod providers
├── shared/widgets/
│   ├── artwork_card.dart              # Pinterest-style card
│   └── artwork_masonry_grid.dart      # Staggered 2-column grid
└── features/
    ├── home/screens/home_screen.dart
    ├── search/screens/search_screen.dart
    ├── artwork_detail/screens/artwork_detail_screen.dart
    ├── collection/screens/collection_screen.dart
    └── profile/screens/profile_screen.dart
```


## 📦 Dependencies ที่ใช้

| Package | Version | ทำไม |
|---------|---------|-------|
| `go_router` | ^13.2.0 | Navigation (Bottom Tab + Detail route) |
| `flutter_riverpod` | ^2.5.1 | State management |
| `dio` | ^5.4.3 | HTTP client สำหรับ Met Museum API |
| `cached_network_image` | ^3.3.1 | โหลดและ cache ภาพอัตโนมัติ |
| `hive_flutter` | ^1.1.0 | Local storage (offline saving) |
| `flutter_staggered_grid_view` | ^0.7.0 | Pinterest-style masonry grid |
| `shimmer` | ^3.0.0 | Loading skeleton animation |
| `google_fonts` | ^6.2.1 | Cormorant Garamond + DM Sans |

---

## ✨ Features

- **Home Feed** — Masonry grid ดึงข้อมูลจาก Met Museum API (Renaissance paintings) พร้อม category filter pills
- **Search** — ค้นหาด้วย keyword + filter: Creator, Medium, Year Range
- **Artwork Detail** — ภาพใหญ่, ประวัติ, ปุ่ม ❤️ Like และ 🔖 Save Offline
- **Collection** — แท็บ "Liked" และ "Saved Offline" (สูงสุด 10 ภาพ) พร้อม progress bar
- **Profile** — ข้อมูลผู้ใช้, สถิติ, toggle settings, Log out

---

## ⚠️ หมายเหตุสำคัญ

### เรื่อง Hive Generated File
ไฟล์ `artwork.g.dart` ถูก pre-generate มาให้แล้ว ไม่ต้อง run `build_runner`
แต่ถ้าต้องการ regenerate สามารถทำได้:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### เรื่อง Met Museum API
- ฟรี ไม่ต้อง API key
- บางครั้งภาพอาจโหลดช้าเพราะ server อยู่ต่างประเทศ
- ต้องมีอินเทอร์เน็ตสำหรับการโหลดครั้งแรก — หลังจากนั้นภาพจะ cache อัตโนมัติ

### Offline Limit
- Save ได้สูงสุด **10 ภาพ** เท่านั้น
- เมื่อเต็มแล้วจะมี dialog แจ้งเตือน

---

## 🐛 Troubleshooting

**`flutter pub get` ล้มเหลว?**
```bash
flutter clean
flutter pub get
```

**Build error เรื่อง Hive adapter?**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Images ไม่โหลด?**
- ตรวจสอบ `AndroidManifest.xml` มี `INTERNET` permission
- ลอง `flutter clean && flutter run`
