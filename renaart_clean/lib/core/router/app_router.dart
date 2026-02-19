import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:renaart/core/router/route_names.dart';
import 'package:renaart/core/theme/app_theme.dart';
import 'package:renaart/features/artwork_detail/screens/artwork_detail_screen.dart';
import 'package:renaart/features/collection/screens/collection_screen.dart';
import 'package:renaart/features/home/screens/home_screen.dart';
import 'package:renaart/features/profile/screens/profile_screen.dart';
import 'package:renaart/features/search/screens/search_screen.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ScaffoldWithNavBar(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (_, __) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.search,
            builder: (_, __) => const SearchScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.collection,
            builder: (_, __) => const CollectionScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: RouteNames.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: RouteNames.artworkDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ArtworkDetailScreen(objectId: id);
      },
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell shell;
  const ScaffoldWithNavBar({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cream,
          border: Border(
            top: BorderSide(color: AppColors.stone.withOpacity(0.2), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: shell.currentIndex,
          onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Collection',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
