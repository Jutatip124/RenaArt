// RenaArt — Renaissance Art gallery app entry point.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'features/home/providers/app_providers.dart';
import 'services/local_storage_service.dart';
import 'services/local_artwork_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Error loading .env: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Firestore offline persistence for better UX and reduced quota usage
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 50 * 1024 * 1024, // 50MB cache limit
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  // Week 3: Initialize Hive local storage
  try {
    await LocalStorageService.instance.init();
  } catch (e) {
    debugPrint('Hive init failed: $e');
  }

  // Keep artwork cache in sync with bundled JSON to avoid stale mapping.
  if (AppConstants.activeSource == ApiSource.localAsset) {
    final storage = LocalStorageService.instance;
    try {
      await storage.clearArtworksCache();
      final artworks =
          await LocalArtworkService.instance.searchArtworks('', maxCount: 400);
      if (artworks.isNotEmpty) {
        await storage.cacheArtworks(artworks);
      }
    } catch (e) {
      debugPrint('Local cache seed failed: $e');
    }
  }

  // Configure image cache limits to prevent excessive memory usage
  PaintingBinding.instance.imageCache.maximumSize = 60; // Max 60 images
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      25 * 1024 * 1024; // 25MB

  // Status bar and navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Catch unhandled Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Catch all unhandled async errors
  runZonedGuarded(
    () => runApp(const ProviderScope(child: RenaArtApp())),
    (error, stack) {
      debugPrint('Unhandled error: $error');
    },
  );
}

class RenaArtApp extends ConsumerWidget {
  const RenaArtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'RenaArt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
