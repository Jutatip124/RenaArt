import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screen/splash_screen.dart';
import '../../features/auth/screen/login_screen.dart';
import '../../features/auth/screen/register_screen.dart';
import '../../features/landing/screen/landing_screen.dart';
import '../../features/home/screen/main_shell.dart';
import '../../features/artwork_detail/screen/artwork_detail_screen.dart';
import '../../features/artwork_detail/screen/image_viewer_screen.dart';
import '../../features/home/providers/app_providers.dart';
import '../../models/artwork_model.dart';

/// Week 4 Spec: Router / Navigation backbone
/// Root → Login (if not authed) | Home (if authed)
/// Tab Nav: Home / Search / Collection / Profile
class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String landing = '/landing';
  static const String artworkDetail = '/artwork/:id';
  static const String imageViewer = '/image-viewer';

  static String artworkPath(String id) => '/artwork/$id';
}

/// Listenable adapter for Riverpod → GoRouter refresh
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(authLoadedProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final user = ref.read(authProvider);
      final loaded = ref.read(authLoadedProvider);
      final loc = state.matchedLocation;

      // Landing page is always accessible
      if (loc == AppRoutes.landing) return null;
      // Always allow splash to show
      if (loc == AppRoutes.splash) return null;
      // Auth not loaded yet — show splash
      if (!loaded) return AppRoutes.splash;

      final isAuthed = user != null;
      final isAuthRoute = loc == AppRoutes.login || loc == AppRoutes.register;
      if (!isAuthed && !isAuthRoute) return AppRoutes.login;
      if (isAuthed && isAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.landing,
        pageBuilder: (context, state) => const NoTransitionPage(child: LandingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/artwork/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final artwork = state.extra as Artwork?;
          return ArtworkDetailScreen(artworkId: id, preloadedArtwork: artwork);
        },
      ),
      GoRoute(
        path: AppRoutes.imageViewer,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return ImageViewerScreen(
            imageUrl: extra['imageUrl'] ?? '',
            title: extra['title'] ?? '',
            artist: extra['artist'] ?? '',
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      ),
    ],
  );
});
