import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screen/splash_screen.dart';
import '../../features/auth/screen/login_screen.dart';
import '../../features/auth/screen/register_screen.dart';
import '../../features/home/screen/main_shell.dart';
import '../../features/artwork_detail/screen/artwork_detail_screen.dart';
import '../../features/home/providers/app_providers.dart';
import '../../models/artwork_model.dart';

abstract class RouteNames {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const artworkDetail = '/artwork/:id';

  static String artworkDetailPath(String id) => '/artwork/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isAuth = auth != null;
      final isGoingToAuth = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.splash;

      if (!isAuth && !isGoingToAuth) return RouteNames.login;
      if (isAuth && state.matchedLocation == RouteNames.splash) {
        return RouteNames.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const SizedBox(),
          ),
        ],
      ),
      GoRoute(
        path: '/artwork/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final artwork = state.extra as Artwork?;
          return ArtworkDetailScreen(artworkId: id, artwork: artwork);
        },
      ),
    ],
  );
});
