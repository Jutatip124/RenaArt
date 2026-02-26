import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/screen/home_screen.dart';
import '../../search/screen/search_screen.dart';
import '../../collection/screen/collection_screen.dart';
import '../../profile/screen/profile_screen.dart';

final _tabIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_tabIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = const [
      HomeScreen(),
      SearchScreen(),
      CollectionScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.dividerLight,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  index: 0,
                  current: index,
                  onTap: () =>
                      ref.read(_tabIndexProvider.notifier).state = 0,
                ),
                _NavItem(
                  label: 'Search',
                  icon: Icons.search,
                  activeIcon: Icons.search,
                  index: 1,
                  current: index,
                  onTap: () =>
                      ref.read(_tabIndexProvider.notifier).state = 1,
                ),
                _NavItem(
                  label: 'Collection',
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  index: 2,
                  current: index,
                  onTap: () =>
                      ref.read(_tabIndexProvider.notifier).state = 2,
                ),
                _NavItem(
                  label: 'Profile',
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  index: 3,
                  current: index,
                  onTap: () =>
                      ref.read(_tabIndexProvider.notifier).state = 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.goldLight : AppColors.sienna;
    final inactiveColor = isDark ? AppColors.darkTextFaint : AppColors.inkFaint;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
