import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/app_providers.dart';
import '../../home/widgets/artwork_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchState();
}

class _SearchState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final results  = ref.watch(searchResultsProvider);
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final textCol  = isDark ? AppColors.darkText   : AppColors.ink;
    final faint    = isDark ? AppColors.darkFaint  : AppColors.inkLight;

    final hasFilters = ref.watch(searchArtistFilterProvider) != null
        || ref.watch(searchPeriodFilterProvider) != null
        || ref.watch(searchMediumFilterProvider) != null;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: Column(children: [
        // ── Header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Art Discovery', style: TextStyle(fontFamily: 'Cormorant',
                fontSize: 28, fontWeight: FontWeight.w700, color: textCol,
                letterSpacing: -0.6)),
            const SizedBox(height: 2),
            Text('Search the Renaissance', style: TextStyle(fontFamily: 'Jost',
                fontSize: 12, color: faint, fontWeight: FontWeight.w300)),
          ]),
        ),
        // ── Search bar ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Search artworks, artists...',
                  prefixIcon: Icon(Icons.search, size: 17, color: faint),
                  suffixIcon: _ctrl.text.isNotEmpty ? IconButton(
                    icon: Icon(Icons.close, size: 15, color: faint),
                    onPressed: () {
                      _ctrl.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  ) : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Filter toggle
            GestureDetector(
              onTap: () => setState(() => _showFilters = !_showFilters),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: hasFilters
                      ? (isDark ? AppColors.gold : AppColors.ink)
                      : (isDark ? AppColors.darkCard : AppColors.canvasCard),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasFilters
                        ? (isDark ? AppColors.gold : AppColors.ink)
                        : (isDark ? AppColors.darkBorder : AppColors.inkHair),
                    width: 0.8,
                  ),
                ),
                child: Icon(Icons.tune, size: 17,
                  color: hasFilters
                      ? (isDark ? AppColors.darkCanvas : Colors.white)
                      : (isDark ? AppColors.darkSub : AppColors.inkMid)),
              ),
            ),
          ]),
        ),
        // ── Filter panel ───────────────────────────────────────────
        AnimatedCrossFade(
          crossFadeState: _showFilters
              ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox.shrink(),
          secondChild: _FilterPanel(isDark: isDark),
        ),
        // ── Count + clear ──────────────────────────────────────────
        results.when(
          loading: () => const SizedBox(height: 6),
          error:   (_, __) => const SizedBox.shrink(),
          data:    (list) => Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
            child: Row(children: [
              Text('${list.length} results', style: TextStyle(fontFamily: 'Jost',
                  fontSize: 11, color: faint)),
              const Spacer(),
              if (hasFilters) GestureDetector(
                onTap: () {
                  ref.read(searchArtistFilterProvider.notifier).state = null;
                  ref.read(searchPeriodFilterProvider.notifier).state = null;
                  ref.read(searchMediumFilterProvider.notifier).state = null;
                },
                child: Text('Clear all', style: TextStyle(fontFamily: 'Jost',
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.gold : AppColors.ink,
                    decoration: TextDecoration.underline,
                    decorationColor: isDark ? AppColors.gold : AppColors.ink)),
              ),
            ]),
          ),
        ),
        // ── Results ────────────────────────────────────────────────
        Expanded(child: results.when(
          loading: () => Center(child: SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 1.5,
                color: isDark ? AppColors.gold : AppColors.ink))),
          error:   (e, _) => Center(child: Text('Error: $e',
              style: const TextStyle(fontFamily: 'Jost', fontSize: 13))),
          data:    (list) {
            if (list.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.search_off, size: 38,
                    color: isDark ? AppColors.darkFaint : AppColors.inkLight),
                const SizedBox(height: 12),
                Text('Nothing found', style: TextStyle(fontFamily: 'Cormorant',
                    fontSize: 20, color: isDark ? AppColors.darkSub : AppColors.inkMid)),
              ]));
            }
            return MasonryGridView.count(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
              crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
              itemCount: list.length,
              itemBuilder: (_, i) => ArtworkCard(artwork: list[i]),
            );
          },
        )),
      ])),
    );
  }
}

// ─── Filter panel ─────────────────────────────────────────────────────────────
class _FilterPanel extends ConsumerWidget {
  final bool isDark;
  const _FilterPanel({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistF = ref.watch(searchArtistFilterProvider);
    final periodF = ref.watch(searchPeriodFilterProvider);
    final mediumF = ref.watch(searchMediumFilterProvider);
    final faint   = isDark ? AppColors.darkFaint : AppColors.inkLight;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.canvasCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.inkHair,
            width: isDark ? 0.5 : 0.8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _FilterGroup('CREATOR', faint, AppStrings.popularArtists.take(6).map((a) =>
          _Chip(a, artistF == a, isDark, () => ref.read(searchArtistFilterProvider.notifier)
              .state = artistF == a ? null : a)).toList()),
        const SizedBox(height: 12),
        _FilterGroup('PERIOD', faint, AppStrings.periods.skip(1).map((p) =>
          _Chip(p, periodF == p, isDark, () => ref.read(searchPeriodFilterProvider.notifier)
              .state = periodF == p ? null : p)).toList()),
        const SizedBox(height: 12),
        _FilterGroup('MEDIUM', faint, AppStrings.mediums.map((m) =>
          _Chip(m, mediumF == m, isDark, () => ref.read(searchMediumFilterProvider.notifier)
              .state = mediumF == m ? null : m)).toList()),
      ]),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String label; final Color color; final List<Widget> chips;
  const _FilterGroup(this.label, this.color, this.chips);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontFamily: 'Jost', fontSize: 9,
          fontWeight: FontWeight.w600, letterSpacing: 1.4, color: color)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: chips),
    ],
  );
}

class _Chip extends StatelessWidget {
  final String label; final bool selected; final bool isDark; final VoidCallback onTap;
  const _Chip(this.label, this.selected, this.isDark, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected
            ? (isDark ? AppColors.gold : AppColors.ink)
            : (isDark ? AppColors.darkRaised : AppColors.canvas),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected
              ? (isDark ? AppColors.gold : AppColors.ink)
              : (isDark ? AppColors.darkBorder : AppColors.inkHair),
          width: 0.8,
        ),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'Jost', fontSize: 12,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected
            ? (isDark ? AppColors.darkCanvas : Colors.white)
            : (isDark ? AppColors.darkSub : AppColors.inkMid))),
    ),
  );
}
