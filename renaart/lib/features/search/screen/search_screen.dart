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
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final artistFilter = ref.watch(searchArtistFilterProvider);
    final periodFilter = ref.watch(searchPeriodFilterProvider);
    final mediumFilter = ref.watch(searchMediumFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasFilters =
        artistFilter != null || periodFilter != null || mediumFilter != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Art Discovery',
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.inkDark,
                ),
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) =>
                          ref.read(searchQueryProvider.notifier).state = v,
                      decoration: InputDecoration(
                        hintText: 'Search artworks, artists, periods...',
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.inkFaint,
                        ),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: AppColors.inkFaint,
                                ),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  ref
                                      .read(searchQueryProvider.notifier)
                                      .state = '';
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showFilters = !_showFilters),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: hasFilters
                            ? AppColors.sienna
                            : isDark
                                ? AppColors.darkCard
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasFilters
                              ? AppColors.sienna
                              : isDark
                                  ? AppColors.darkBorder
                                  : AppColors.dividerLight,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.tune,
                        size: 18,
                        color: hasFilters
                            ? Colors.white
                            : isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.inkMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filters panel
            AnimatedCrossFade(
              crossFadeState: _showFilters
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              firstChild: const SizedBox.shrink(),
              secondChild: _FiltersPanel(isDark: isDark),
            ),
            // Results count
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${results.length} artwork${results.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextFaint
                          : AppColors.inkFaint,
                    ),
                  ),
                  if (hasFilters)
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(searchArtistFilterProvider.notifier)
                            .state = null;
                        ref
                            .read(searchPeriodFilterProvider.notifier)
                            .state = null;
                        ref
                            .read(searchMediumFilterProvider.notifier)
                            .state = null;
                      },
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 12,
                          color: AppColors.sienna,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Results grid
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: isDark
                                ? AppColors.darkTextFaint
                                : AppColors.inkFaint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No artworks found',
                            style: TextStyle(
                              fontFamily: 'Cormorant',
                              fontSize: 20,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.inkLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : MasonryGridView.count(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      itemCount: results.length,
                      itemBuilder: (context, index) =>
                          ArtworkCard(artwork: results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersPanel extends ConsumerWidget {
  final bool isDark;
  const _FiltersPanel({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistFilter = ref.watch(searchArtistFilterProvider);
    final periodFilter = ref.watch(searchPeriodFilterProvider);
    final mediumFilter = ref.watch(searchMediumFilterProvider);
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.inkMedium;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator
          Text(
            'Creator',
            style: TextStyle(
              fontFamily: 'Jost',
              fontSize: 11,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: AppStrings.popularArtists.take(6).map((artist) {
              final selected = artistFilter == artist;
              return _FilterChip(
                label: artist,
                selected: selected,
                isDark: isDark,
                onTap: () {
                  ref.read(searchArtistFilterProvider.notifier).state =
                      selected ? null : artist;
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Period
          Text(
            'Period',
            style: TextStyle(
              fontFamily: 'Jost',
              fontSize: 11,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: AppStrings.periods.skip(1).map((period) {
              final selected = periodFilter == period;
              return _FilterChip(
                label: period,
                selected: selected,
                isDark: isDark,
                onTap: () {
                  ref.read(searchPeriodFilterProvider.notifier).state =
                      selected ? null : period;
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Medium
          Text(
            'Medium',
            style: TextStyle(
              fontFamily: 'Jost',
              fontSize: 11,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: AppStrings.mediums.map((medium) {
              final selected = mediumFilter == medium;
              return _FilterChip(
                label: medium,
                selected: selected,
                isDark: isDark,
                onTap: () {
                  ref.read(searchMediumFilterProvider.notifier).state =
                      selected ? null : medium;
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.sienna
              : isDark
                  ? AppColors.darkBg
                  : AppColors.parchment,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.sienna
                : isDark
                    ? AppColors.darkBorder
                    : AppColors.dividerLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 12,
            color: selected
                ? Colors.white
                : isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.inkMedium,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
