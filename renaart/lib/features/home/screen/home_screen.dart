import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── APP BAR ───────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to',
                  style: textTheme.labelMedium,
                ),
                Text(
                  'RenaArt',
                  style: textTheme.headlineLarge,
                ),
              ],
            ),
            actions: [
              Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: textTheme.bodyMedium?.color,
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(46),
              child: _PeriodChips(
                selected: period,
                onSelect: (p) =>
                    ref.read(selectedPeriodProvider.notifier).state = p,
              ),
            ),
          ),

          // ─── OFFLINE BANNER ───────────────────────────────
          if (!isOnline)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: colorScheme.primary.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off,
                        size: 14, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.offlineBanner,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── SECTION HEADER ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
              child: Row(
                children: [
                  Text(
                    'For You',
                    style: textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  if (feedAsync.isLoading)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.3,
                        color: colorScheme.primary,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Text(
                          'See all',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                            size: 14,
                            color: textTheme.bodyMedium?.color),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // ─── GRID ─────────────────────────────────────────
          feedAsync.when(
            loading: () =>
                const SliverToBoxAdapter(child: _SkeletonGrid()),
            error: (e, _) => const SliverToBoxAdapter(
                child: _ErrorView()),
            data: (artworks) {
              if (artworks.isEmpty) {
                return const SliverToBoxAdapter(
                    child: _EmptyView());
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childCount: artworks.length,
                  itemBuilder: (_, i) =>
                      ArtworkCard(artwork: artworks[i]),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
              child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _PeriodChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _PeriodChips({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: AppStrings.periods.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final p = AppStrings.periods[i];
          final active = p == selected;

          return GestureDetector(
            onTap: () => onSelect(p),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: active
                    ? colorScheme.primary
                    : colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? colorScheme.primary
                      : colorScheme.outline,
                  width: 0.8,
                ),
              ),
              child: Text(
                p,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: active
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: active
                      ? (isDark
                          ? theme.scaffoldBackgroundColor
                          : Colors.white)
                      : textTheme.bodyMedium?.color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 14),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: 8,
        itemBuilder: (_, i) => Container(
          height: i.isEven ? 200 : 155,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    final textTheme =
        Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 36),
            const SizedBox(height: 14),
            Text(
              'Could not load artworks',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final textTheme =
        Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.museum_outlined,
                size: 36),
            const SizedBox(height: 14),
            Text(
              'No artworks found',
              style: textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}