import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renaart/core/theme/app_theme.dart';
import 'package:renaart/services/providers.dart';
import 'package:renaart/shared/widgets/artwork_masonry_grid.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _categories = [
    'All',
    'High Renaissance',
    'Portraits',
    'Sculpture',
    'Fresco',
    'Flemish',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homeFeedProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Rena',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        color: AppColors.sienna,
                        letterSpacing: 1,
                      ),
                    ),
                    TextSpan(
                      text: 'Art',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sienna,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                const SizedBox(width: 4),
              ],
            ),

            // ── Category Pills ────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final active = i == 0;
                    return FilterChip(
                      label: Text(_categories[i]),
                      selected: active,
                      onSelected: (_) {},
                      labelStyle: TextStyle(
                        color: active ? Colors.white : AppColors.stone,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: AppColors.parchment,
                      selectedColor: AppColors.ink,
                      checkmarkColor: Colors.white,
                      showCheckmark: false,
                      side: BorderSide(
                        color:
                            active ? AppColors.ink : AppColors.stone.withOpacity(0.4),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Feed Label ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  'SUGGESTED FOR YOU',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),

            // ── Masonry Grid ──────────────────────────────────────
            SliverToBoxAdapter(
              child: feedAsync.when(
                loading: () => _buildShimmer(),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_off, color: AppColors.stone, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Cannot reach the museum.\nPlease check your connection.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(homeFeedProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sienna,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (artworks) => artworks.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No artworks found.'),
                        ),
                      )
                    : ArtworkMasonryGrid(artworks: artworks),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _shimmerCard(200)),
              const SizedBox(width: 8),
              Expanded(child: _shimmerCard(140)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _shimmerCard(130)),
              const SizedBox(width: 8),
              Expanded(child: _shimmerCard(180)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard(double height) {
    return Shimmer.fromColors(
      baseColor: AppColors.parchment,
      highlightColor: AppColors.cream,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
