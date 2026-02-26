import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/app_providers.dart';
import '../../home/widgets/artwork_card.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoriteArtworksProvider);
    final offlineArtworks = ref.watch(offlineArtworksProvider);
    final offlineIds = ref.watch(offlineProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Renaissance',
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.inkDark,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.filter_list,
                    color: isDark
                        ? AppColors.darkTextFaint
                        : AppColors.inkFaint,
                  ),
                ],
              ),
            ),
            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.favorite, size: 14, color: AppColors.heartRed),
                  const SizedBox(width: 4),
                  Text(
                    'Liked (${favorites.length})',
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.inkLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.download_done,
                    size: 14,
                    color: AppColors.offlineBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Saved Offline (${offlineIds.length}/${AppConstants.maxOfflineArtworks})',
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.inkLight,
                    ),
                  ),
                ],
              ),
            ),
            // Offline storage bar (shown only in offline tab)
            if (_tab.index == 1) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _OfflineStorageBar(
                  count: offlineIds.length,
                  max: AppConstants.maxOfflineArtworks,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.dividerLight,
                  width: 0.5,
                ),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  color: AppColors.sienna,
                  borderRadius: BorderRadius.circular(9),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                labelColor: Colors.white,
                unselectedLabelColor:
                    isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
                tabs: const [
                  Tab(text: 'Liked'),
                  Tab(text: 'Offline Library'),
                ],
              ),
            ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  // Liked tab
                  favorites.isEmpty
                      ? _EmptyState(
                          icon: Icons.favorite_border,
                          title: 'No liked artworks yet',
                          subtitle: 'Tap the heart on any artwork to save it here.',
                          isDark: isDark,
                        )
                      : MasonryGridView.count(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          itemCount: favorites.length,
                          itemBuilder: (context, index) =>
                              ArtworkCard(artwork: favorites[index]),
                        ),
                  // Offline tab
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (offlineArtworks.isEmpty)
                        Expanded(
                          child: _EmptyState(
                            icon: Icons.download_outlined,
                            title: 'No offline artworks',
                            subtitle: 'Save artworks to view them without internet.',
                            isDark: isDark,
                          ),
                        )
                      else ...[
                        Expanded(
                          child: MasonryGridView.count(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            itemCount: offlineArtworks.length,
                            itemBuilder: (context, index) => GestureDetector(
                              onLongPress: () =>
                                  _showRemoveDialog(context, ref, offlineArtworks[index].id, isDark),
                              child: ArtworkCard(artwork: offlineArtworks[index]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Text(
                            'Long press any artwork to remove from offline',
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextFaint
                                  : AppColors.inkFaint,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(
      BuildContext context, WidgetRef ref, String id, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          'Remove from offline?',
          style: TextStyle(
            fontFamily: 'Cormorant',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.inkDark,
          ),
        ),
        content: Text(
          'This artwork will no longer be available without internet.',
          style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Jost',
                color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(offlineProvider.notifier).remove(id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Remove',
              style: TextStyle(
                fontFamily: 'Jost',
                color: AppColors.heartRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineStorageBar extends StatelessWidget {
  final int count;
  final int max;
  final bool isDark;

  const _OfflineStorageBar({
    required this.count,
    required this.max,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Offline Library',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkText : AppColors.inkDark,
                ),
              ),
              Text(
                '$count/$max',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: count >= max ? AppColors.heartRed : AppColors.offlineBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / max,
              backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
              color:
                  count >= max ? AppColors.heartRed : AppColors.offlineBlue,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 13,
                color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
