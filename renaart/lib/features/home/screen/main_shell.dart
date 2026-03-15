// Bottom navigation shell — icon-only nav bar wrapping Home, Search, Collection, Profile tabs.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/screen/home_screen.dart';
import '../../search/screen/search_screen.dart';
import '../../collection/screen/collection_screen.dart';
import '../../profile/screen/profile_screen.dart';

final _tabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _screens = [
    HomeScreen(), SearchScreen(), CollectionScreen(), ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx    = ref.watch(_tabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg  = isDark ? AppColors.darkSurface : AppColors.canvasCard;
    final border = isDark ? AppColors.darkBorder  : AppColors.inkHair;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: idx, children: _screens),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: border, width: 0.8)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(height: 50,
            child: Row(children: [
              _NavItem(icon: Icons.home_outlined,  activeIcon: Icons.home,
                  label: 'Home',       idx: 0, current: idx, isDark: isDark,
                  onTap: () => ref.read(_tabProvider.notifier).state = 0),
              _NavItem(icon: Icons.search,          activeIcon: Icons.search,
                  label: 'Search',     idx: 1, current: idx, isDark: isDark,
                  onTap: () => ref.read(_tabProvider.notifier).state = 1),
              _NavItem(icon: Icons.favorite_border, activeIcon: Icons.favorite,
                  label: 'Collection', idx: 2, current: idx, isDark: isDark,
                  onTap: () => ref.read(_tabProvider.notifier).state = 2),
              _NavItem(icon: Icons.person_outline,  activeIcon: Icons.person,
                  label: 'Profile',    idx: 3, current: idx, isDark: isDark,
                  onTap: () => ref.read(_tabProvider.notifier).state = 3),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int idx, current;
  final bool isDark;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.activeIcon, required this.label,
      required this.idx, required this.current, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = idx == current;
    // Active: Primary (black/white), Inactive: Secondary text
    final activeColor   = isDark ? AppColors.darkText  : AppColors.ink;
    final inactiveColor = isDark ? AppColors.darkSub   : AppColors.inkMid;

    return Expanded(child: InkWell(
      onTap: onTap, splashColor: Colors.transparent, highlightColor: Colors.transparent,
      child: Center(
        child: Icon(active ? activeIcon : icon, size: 24,
            color: active ? activeColor : inactiveColor),
      ),
    ));
  }
}
