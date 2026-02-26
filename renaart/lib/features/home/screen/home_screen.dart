import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/app_providers.dart';
import '../../home/widgets/artwork_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artworks = ref.watch(homeFeedProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
            title: Text(
              'RenaArt',
              style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 26,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkText : AppColors.inkDark,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_outlined,
                  color: isDark ? AppColors.darkText : AppColors.inkDark,
                ),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: _PeriodFilter(
                selected: selectedPeriod,
                onSelected: (p) =>
                    ref.read(selectedPeriodProvider.notifier).state = p,
                isDark: isDark,
              ),
            ),
          ),
          // Suggestion header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'SUGGESTED FOR YOU',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
                ),
              ),
            ),
          ),
          // Masonry Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childCount: artworks.length,
              itemBuilder: (context, index) {
                return ArtworkCard(artwork: artworks[index]);
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final bool isDark;

  const _PeriodFilter({
    required this.selected,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: AppStrings.periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final period = AppStrings.periods[index];
          final isSelected = period == selected;
          return GestureDetector(
            onTap: () => onSelected(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.sienna
                    : isDark
                        ? AppColors.darkCard
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.sienna
                      : isDark
                          ? AppColors.darkBorder
                          : AppColors.dividerLight,
                  width: 0.5,
                ),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.inkMedium,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
