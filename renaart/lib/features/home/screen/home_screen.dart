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
    final feedAsync = ref.watch(homeFeedProvider);
    final period = ref.watch(selectedPeriodProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
            title: Text('RenaArt', style: TextStyle(
              fontFamily: 'Cormorant', fontSize: 26,
              fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkText : AppColors.inkDark,
            )),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none_outlined,
                  color: isDark ? AppColors.darkText : AppColors.inkDark),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: _PeriodChips(selected: period, isDark: isDark,
                onSelected: (p) =>
                    ref.read(selectedPeriodProvider.notifier).state = p),
            ),
          ),
          // ─── Offline Banner (Week 3: offline strategy) ───────────────────
          if (!isOnline)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.offlineBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.offlineBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(children: [
                  const Icon(Icons.wifi_off, size: 14, color: AppColors.offlineBlue),
                  const SizedBox(width: 8),
                  Text(AppStrings.offlineBanner, style: const TextStyle(
                    fontFamily: 'Jost', fontSize: 12,
                    color: AppColors.offlineBlue, fontWeight: FontWeight.w500,
                  )),
                ]),
              ),
            ),
          // ─── Suggestion Header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SUGGESTED FOR YOU', style: TextStyle(
                    fontFamily: 'Jost', fontSize: 10, letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
                  )),
                  if (feedAsync.isLoading)
                    const SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: AppColors.sienna,
                      )),
                ],
              ),
            ),
          ),
          // ─── Masonry Grid ─────────────────────────────────────────────────
          feedAsync.when(
            loading: () => const SliverToBoxAdapter(child: _LoadingGrid()),
            error: (e, _) => SliverToBoxAdapter(child: _ErrorView(message: e.toString())),
            data: (artworks) {
              if (artworks.isEmpty) {
                return const SliverToBoxAdapter(child: _EmptyView());
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childCount: artworks.length,
                  itemBuilder: (_, i) => ArtworkCard(artwork: artworks[i]),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _PeriodChips extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelected;
  const _PeriodChips({required this.selected, required this.isDark, required this.onSelected});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: AppStrings.periods.length,
      separatorBuilder: (_, __) => const SizedBox(width: 7),
      itemBuilder: (_, i) {
        final p = AppStrings.periods[i];
        final active = p == selected;
        return GestureDetector(
          onTap: () => onSelected(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: active ? AppColors.sienna
                : isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? AppColors.sienna
                  : isDark ? AppColors.darkBorder : AppColors.divider,
                width: 0.5,
              ),
            ),
            child: Text(p, style: TextStyle(
              fontFamily: 'Jost', fontSize: 12,
              fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              color: active ? Colors.white
                : isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
            )),
          ),
        );
      },
    ),
  );
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: 8,
        itemBuilder: (_, i) => _SkeletonCard(height: i.isEven ? 200.0 : 160.0, isDark: isDark),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;
  final bool isDark;
  const _SkeletonCard({required this.height, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.parchmentDark,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off, size: 40,
            color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint),
          const SizedBox(height: 12),
          Text('Could not load artworks', style: TextStyle(
            fontFamily: 'Cormorant', fontSize: 20,
            color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
          )),
          const SizedBox(height: 6),
          Text('Check your connection and try again.', style: TextStyle(
            fontFamily: 'Jost', fontSize: 13,
            color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
          ), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.museum_outlined, size: 40,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint),
        const SizedBox(height: 12),
        Text('No artworks found', style: TextStyle(
          fontFamily: 'Cormorant', fontSize: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
        )),
      ]),
    ));
  }
}
