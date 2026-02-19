import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renaart/core/router/app_router.dart';
import 'package:renaart/core/theme/app_theme.dart';
import 'package:renaart/services/providers.dart';
import 'package:renaart/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive storage
  final storage = StorageService();
  await storage.init();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the initialized StorageService into Riverpod
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: const RenaArtApp(),
    ),
  );
}

class RenaArtApp extends StatelessWidget {
  const RenaArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RenaArt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
