import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/screen/home_screen.dart';
import '../../search/screen/search_screen.dart';
import '../../collection/screen/collection_screen.dart';
import '../../profile/screen/profile_screen.dart';

final _currentTabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _screens = [
    HomeScreen(),
    SearchScreen(),
    CollectionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(_currentTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: tabIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surfaceWhite,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.divider,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                _TabItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                  current: tabIndex,
                  isDark: isDark,
                  onTap: () => ref.read(_currentTabProvider.notifier).state = 0,
                ),
                _TabItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: 'Search',
                  index: 1,
                  current: tabIndex,
                  isDark: isDark,
                  onTap: () => ref.read(_currentTabProvider.notifier).state = 1,
                ),
                _TabItem(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: 'Collection',
                  index: 2,
                  current: tabIndex,
                  isDark: isDark,
                  onTap: () => ref.read(_currentTabProvider.notifier).state = 2,
                ),
                _TabItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 3,
                  current: tabIndex,
                  isDark: isDark,
                  onTap: () => ref.read(_currentTabProvider.notifier).state = 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final bool isDark;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
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
