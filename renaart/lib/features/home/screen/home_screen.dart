import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/app_providers.dart';
import '../../home/widgets/artwork_card.dart';

// Home Screen — "Welcome to Arts Gallery" layout (Image 1 reference)
// - Section header "For You" with arrow
// - Period filter chips (pill style, black active / outlined inactive)
// - Masonry 2-col grid
// Dark mode: cinematic dark bg, gold active chip
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
    final sub       = isDark ? AppColors.darkSub    : AppColors.inkMid;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(slivers: [
        // ── AppBar ──────────────────────────────────────────────────
        SliverAppBar(
          floating: true, snap: true,
          backgroundColor: bg,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome to', style: TextStyle(fontFamily: 'Jost', fontSize: 11,
                fontWeight: FontWeight.w400, letterSpacing: 0.3, color: sub)),
            Text('Arts Gallery', style: TextStyle(fontFamily: 'Cormorant', fontSize: 26,
                fontWeight: FontWeight.w700, fontStyle: FontStyle.italic,
                color: text, letterSpacing: -0.5, height: 1.0)),
          ]),
          actions: [
            Container(
              width: 34, height: 34, margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkCard : AppColors.canvasTone,
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.inkHair),
              ),
              child: Icon(Icons.person_outline, size: 17,
                  color: isDark ? AppColors.darkSub : AppColors.inkMid),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(46),
            child: _PeriodChips(selected: period, isDark: isDark,
              onSelect: (p) =>
                  ref.read(selectedPeriodProvider.notifier).state = p),
          ),
        ),
        // ── Offline Banner ──────────────────────────────────────────
        if (!isOnline)
          SliverToBoxAdapter(child: _OfflineBanner(isDark: isDark)),
        // ── "For You" section header ────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(children: [
              Text('For You', style: TextStyle(fontFamily: 'Cormorant',
                  fontSize: 20, fontWeight: FontWeight.w600, color: text)),
              const Spacer(),
              if (feedAsync.isLoading)
                SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.3,
                      color: isDark ? AppColors.gold : AppColors.inkLight))
              else
                Row(children: [
                  Text('See all', style: TextStyle(fontFamily: 'Jost',
                      fontSize: 12, color: isDark ? AppColors.darkFaint : AppColors.inkLight)),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 13,
                      color: isDark ? AppColors.darkFaint : AppColors.inkLight),
                ]),
            ]),
          ),
        ),
        // ── Grid ────────────────────────────────────────────────────
        feedAsync.when(
          loading: () => const SliverToBoxAdapter(child: _SkeletonGrid()),
          error:   (e, _) => SliverToBoxAdapter(child: _ErrorView(isDark: isDark)),
          data:    (artworks) {
            if (artworks.isEmpty) return SliverToBoxAdapter(
                child: _EmptyView(isDark: isDark));
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
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemBuilder: (_, i) {
        final p      = AppStrings.periods[i];
        final active = p == selected;
        return GestureDetector(
          onTap: () => onSelect(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              // Light: black fill active / white outlined inactive
              // Dark:  gold fill active / dark card inactive
              color:  active
                  ? (isDark ? AppColors.gold : AppColors.ink)
                  : (isDark ? AppColors.darkCard : AppColors.canvasCard),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? (isDark ? AppColors.gold : AppColors.ink)
                    : (isDark ? AppColors.darkBorder : AppColors.inkHair),
                width: 0.8,
              ),
            ),
            child: Text(p,
              style: TextStyle(fontFamily: 'Jost', fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active
                    ? (isDark ? AppColors.darkCanvas : Colors.white)
                    : (isDark ? AppColors.darkSub : AppColors.inkMid),
                letterSpacing: 0.1,
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
      color: AppColors.saveBlue.withOpacity(isDark ? 0.14 : 0.08),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.saveBlue.withOpacity(0.25)),
    ),
    child: Row(children: [
      Icon(Icons.wifi_off, size: 13, color: AppColors.saveBlue),
      const SizedBox(width: 8),
      Text(AppStrings.offlineBanner, style: const TextStyle(
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
            borderRadius: BorderRadius.circular(8),
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
