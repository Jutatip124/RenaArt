// RenaArt — Renaissance Art gallery app entry point.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/home/providers/app_providers.dart';
import 'services/local_storage_service.dart';

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
  } catch (_) {
    // Firebase init failed — app will fall back to local asset data
  }

  // Week 3: Initialize Hive local storage
  try {
    await LocalStorageService.instance.init();
  } catch (_) {
    // Hive init failed — non-fatal, features degrade gracefully
  }

  // Status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
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