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
    final period    = ref.watch(selectedPeriodProvider);
    final isOnline  = ref.watch(isOnlineProvider);
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bg        = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final text      = isDark ? AppColors.darkText   : AppColors.ink;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(slivers: [
        // ── AppBar ──────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: bg,
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : AppColors.ink,
                BlendMode.srcIn,
              ),
              child: Image.asset('assets/images/logo_dark.png',
                  width: 28, height: 28),
            ),
            const SizedBox(width: 8),
            Text('RenaArt', style: TextStyle(fontFamily: 'Cormorant', fontSize: 26,
                fontWeight: FontWeight.w700, fontStyle: FontStyle.italic,
                color: text, letterSpacing: -0.5, height: 1.0)),
          ]),
          actions: const [],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(46),
            child: _PeriodChips(selected: period, isDark: isDark,
              onSelect: (p) =>
                  ref.read(selectedPeriodProvider.notifier).state = p),
          ),
        ),
        // ── Offline Banner ──────────────────────────────────────
        if (!isOnline)
          SliverToBoxAdapter(child: _OfflineBanner(isDark: isDark)),
        
        // ── Grid ────────────────────────────────────────────────
        feedAsync.when(
          loading: () => const SliverToBoxAdapter(child: _SkeletonGrid()),
          error:   (e, _) => SliverToBoxAdapter(child: _ErrorView(isDark: isDark)),
          data:    (artworks) {
            if (artworks.isEmpty) {
              return SliverToBoxAdapter(child: _EmptyView(isDark: isDark));
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
                childCount: artworks.length,
                itemBuilder: (_, i) => ArtworkCard(artwork: artworks[i]),
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]),
    );
  }
}

// ─── Period Chips ─────────────────────────────────────────────────────────────
class _PeriodChips extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelect;
  const _PeriodChips({required this.selected, required this.isDark, required this.onSelect});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: AppStrings.periods.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final p      = AppStrings.periods[i];
        final active = p == selected;
        return GestureDetector(
          onTap: () => onSelect(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? (isDark ? AppColors.darkText : AppColors.ink)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: active
                  ? null
                  : Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.inkHair,
                      width: 1.0,
                    ),
            ),
            child: Text(p,
              style: TextStyle(fontFamily: 'Jost', fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active
                    ? (isDark ? AppColors.darkBg : Colors.white)
                    : (isDark ? AppColors.darkSub : AppColors.ink),
              )),
          ),
        );
      },
    ),
  );
}

// ─── Offline Banner ───────────────────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  final bool isDark;
  const _OfflineBanner({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: AppColors.saveBlue.withValues(alpha: isDark ? 0.14 : 0.08),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.saveBlue.withValues(alpha: 0.25)),
    ),
    child: const Row(children: [
      Icon(Icons.wifi_off, size: 13, color: AppColors.saveBlue),
      SizedBox(width: 8),
      Text(AppStrings.offlineBanner, style: TextStyle(
          fontFamily: 'Jost', fontSize: 12, color: AppColors.saveBlue,
          fontWeight: FontWeight.w500)),
    ]),
  );
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: MasonryGridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
        itemCount: 8,
        itemBuilder: (_, i) => Container(
          height: i.isEven ? 200.0 : 155.0,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.canvasTone,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─── States ───────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final bool isDark;
  const _ErrorView({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.wifi_off, size: 36,
          color: isDark ? AppColors.darkFaint : AppColors.inkLight),
      const SizedBox(height: 14),
      Text('Could not load artworks', style: TextStyle(fontFamily: 'Cormorant',
          fontSize: 20, color: isDark ? AppColors.darkSub : AppColors.inkMid)),
      const SizedBox(height: 6),
      Text('Check your connection and try again.', textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Jost', fontSize: 13,
            color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
    ]),
  ));
}

class _EmptyView extends StatelessWidget {
  final bool isDark;
  const _EmptyView({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.museum_outlined, size: 36,
          color: isDark ? AppColors.darkFaint : AppColors.inkLight),
      const SizedBox(height: 14),
      Text('No artworks found', style: TextStyle(fontFamily: 'Cormorant',
          fontSize: 20, color: isDark ? AppColors.darkSub : AppColors.inkMid)),
    ]),
  ));
}