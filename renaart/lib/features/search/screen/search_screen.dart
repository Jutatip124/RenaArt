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
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _clearFilters() {
    ref.read(searchArtistFilterProvider.notifier).state = null;
    ref.read(searchPeriodFilterProvider.notifier).state = null;
    ref.read(searchMediumFilterProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ─── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text('Art Discovery', style: TextStyle(
              fontFamily: 'Cormorant', fontSize: 28, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.inkDark,
            )),
          ),
          // ─── Search Bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                  decoration: InputDecoration(
                    hintText: 'Search artworks, artists, periods...',
                    prefixIcon: const Icon(Icons.search, size: 18,
                        color: AppColors.inkFaint),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16,
                                color: AppColors.inkFaint),
                            onPressed: () {
                              _ctrl.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Filter toggle button
              Consumer(builder: (_, ref, __) {
                final hasFilters = ref.watch(searchArtistFilterProvider) != null ||
                    ref.watch(searchPeriodFilterProvider) != null ||
                    ref.watch(searchMediumFilterProvider) != null;
                return GestureDetector(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: hasFilters ? AppColors.sienna
                          : isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasFilters ? AppColors.sienna
                            : isDark ? AppColors.darkBorder : AppColors.divider,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(Icons.tune, size: 18,
                      color: hasFilters ? Colors.white
                          : isDark ? AppColors.darkTextSecondary : AppColors.inkMedium),
                  ),
                );
              }),
            ]),
          ),
          // ─── Filter Panel ──────────────────────────────────────────────────
          AnimatedCrossFade(
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox.shrink(),
            secondChild: _FilterPanel(isDark: isDark),
          ),
          // ─── Results count ─────────────────────────────────────────────────
          resultsAsync.when(
            loading: () => const SizedBox(height: 8),
            error: (_, __) => const SizedBox.shrink(),
            data: (artworks) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${artworks.length} artwork${artworks.length != 1 ? 's' : ''} found',
                    style: TextStyle(fontFamily: 'Jost', fontSize: 12,
                      color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint)),
                  Consumer(builder: (_, ref, __) {
                    final hasF = ref.watch(searchArtistFilterProvider) != null ||
                        ref.watch(searchPeriodFilterProvider) != null ||
                        ref.watch(searchMediumFilterProvider) != null;
                    if (!hasF) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: _clearFilters,
                      child: const Text('Clear all', style: TextStyle(
                        fontFamily: 'Jost', fontSize: 12,
                        color: AppColors.sienna, fontWeight: FontWeight.w500,
                      )),
                    );
                  }),
                ],
              ),
            ),
          ),
          // ─── Results Grid ──────────────────────────────────────────────────
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(
                strokeWidth: 1.5, color: AppColors.sienna,
              )),
              error: (e, _) => Center(child: Text('Error: $e',
                style: const TextStyle(fontFamily: 'Jost', fontSize: 13))),
              data: (artworks) {
                if (artworks.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.search_off, size: 44,
                        color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint),
                    const SizedBox(height: 12),
                    Text('No artworks found', style: TextStyle(
                      fontFamily: 'Cormorant', fontSize: 20,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
                    )),
                  ]));
                }
                return MasonryGridView.count(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount: artworks.length,
                  itemBuilder: (_, i) => ArtworkCard(artwork: artworks[i]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Filter Panel ─────────────────────────────────────────────────────────────
class _FilterPanel extends ConsumerWidget {
  final bool isDark;
  const _FilterPanel({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistF = ref.watch(searchArtistFilterProvider);
    final periodF = ref.watch(searchPeriodFilterProvider);
    final mediumF = ref.watch(searchMediumFilterProvider);
    final faint = isDark ? AppColors.darkTextFaint : AppColors.inkFaint;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.divider, width: 0.5,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _FilterSection(
          label: 'Creator',
          faint: faint,
          chips: AppStrings.popularArtists.take(6).map((a) => _FilterChip(
            label: a, isDark: isDark, selected: artistF == a,
            onTap: () => ref.read(searchArtistFilterProvider.notifier).state =
                artistF == a ? null : a,
          )).toList(),
        ),
        const SizedBox(height: 12),
        _FilterSection(
          label: 'Period',
          faint: faint,
          chips: AppStrings.periods.skip(1).map((p) => _FilterChip(
            label: p, isDark: isDark, selected: periodF == p,
            onTap: () => ref.read(searchPeriodFilterProvider.notifier).state =
                periodF == p ? null : p,
          )).toList(),
        ),
        const SizedBox(height: 12),
        _FilterSection(
          label: 'Medium',
          faint: faint,
          chips: AppStrings.mediums.map((m) => _FilterChip(
            label: m, isDark: isDark, selected: mediumF == m,
            onTap: () => ref.read(searchMediumFilterProvider.notifier).state =
                mediumF == m ? null : m,
          )).toList(),
        ),
      ]),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String label;
  final Color faint;
  final List<Widget> chips;
  const _FilterSection({required this.label, required this.faint, required this.chips});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(), style: TextStyle(
        fontFamily: 'Jost', fontSize: 10, letterSpacing: 1.0,
        fontWeight: FontWeight.w500, color: faint,
      )),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: chips),
    ],
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected,
      required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? AppColors.sienna
            : isDark ? AppColors.darkBg : AppColors.parchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.sienna
              : isDark ? AppColors.darkBorder : AppColors.divider,
        ),
      ),
      child: Text(label, style: TextStyle(
        fontFamily: 'Jost', fontSize: 12,
        fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
        color: selected ? Colors.white
            : isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
      )),
    ),
  );
}
