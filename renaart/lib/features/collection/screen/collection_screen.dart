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
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
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
    final offlineCount = ref.watch(offlineIdsProvider).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: SafeArea(child: Column(children: [
        // ─── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(children: [
            Expanded(child: Text('My Renaissance', style: TextStyle(
              fontFamily: 'Cormorant', fontSize: 28, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.inkDark,
            ))),
          ]),
        ),
        // ─── Stats Row ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(children: [
            const Icon(Icons.favorite, size: 13, color: AppColors.heartRed),
            const SizedBox(width: 4),
            Text('${favorites.length} liked', style: TextStyle(
              fontFamily: 'Jost', fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
            )),
            const SizedBox(width: 14),
            const Icon(Icons.download_done, size: 13, color: AppColors.offlineBlue),
            const SizedBox(width: 4),
            Text('$offlineCount/${AppConstants.maxOfflineArtworks} offline', style: TextStyle(
              fontFamily: 'Jost', fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
            )),
          ]),
        ),
        // ─── Offline Storage Bar (only in offline tab) ───────────────────────
        if (_tab.index == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _OfflineStorageBar(
              count: offlineCount,
              max: AppConstants.maxOfflineArtworks,
              isDark: isDark,
            ),
          ),
        // ─── Tab Bar ─────────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.divider, width: 0.5,
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
            labelColor: Colors.white,
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary : AppColors.inkMedium,
            labelStyle: const TextStyle(
              fontFamily: 'Jost', fontSize: 13, fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Jost', fontSize: 13, fontWeight: FontWeight.w400,
            ),
            tabs: const [Tab(text: 'Liked'), Tab(text: 'Offline Library')],
          ),
        ),
        // ─── Content ──────────────────────────────────────────────────────────
        Expanded(child: TabBarView(controller: _tab, children: [
          // Liked Tab
          favorites.isEmpty
              ? _EmptyState(
                  icon: Icons.favorite_border,
                  title: 'No liked artworks yet',
                  subtitle: 'Tap the heart on any artwork to save it here.',
                  isDark: isDark,
                )
              : MasonryGridView.count(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount: favorites.length,
                  itemBuilder: (_, i) => ArtworkCard(artwork: favorites[i]),
                ),
          // Offline Library Tab
          offlineArtworks.isEmpty
              ? _EmptyState(
                  icon: Icons.download_outlined,
                  title: 'No offline artworks',
                  subtitle: 'Save artworks to view them without internet.',
                  isDark: isDark,
                )
              : Column(children: [
                  Expanded(
                    child: MasonryGridView.count(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      itemCount: offlineArtworks.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onLongPress: () => _confirmRemove(
                          context, ref, offlineArtworks[i].id, isDark),
                        child: ArtworkCard(artwork: offlineArtworks[i]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Text(
                      'Long press any artwork to remove from offline library',
                      style: TextStyle(fontFamily: 'Jost', fontSize: 11,
                        color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
        ])),
      ])),
    );
  }

  void _confirmRemove(BuildContext ctx, WidgetRef ref, String id, bool isDark) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text('Remove from offline?', style: TextStyle(
          fontFamily: 'Cormorant', fontSize: 20, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.inkDark,
        )),
        content: Text(
          'This artwork will no longer be available without internet.',
          style: TextStyle(fontFamily: 'Jost', fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(
              fontFamily: 'Jost',
              color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
            )),
          ),
          TextButton(
            onPressed: () {
              ref.read(offlineIdsProvider.notifier).remove(id);
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(
              fontFamily: 'Jost', color: AppColors.heartRed, fontWeight: FontWeight.w500,
            )),
          ),
        ],
      ),
    );
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _OfflineStorageBar extends StatelessWidget {
  final int count;
  final int max;
  final bool isDark;
  const _OfflineStorageBar({required this.count, required this.max, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.divider, width: 0.5,
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Offline Library', style: TextStyle(
          fontFamily: 'Jost', fontSize: 13, fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkText : AppColors.inkDark,
        )),
        Text('$count/$max ${AppStrings.offlineStorageLabel}', style: TextStyle(
          fontFamily: 'Jost', fontSize: 13, fontWeight: FontWeight.w600,
          color: count >= max ? AppColors.heartRed : AppColors.offlineBlue,
        )),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: count / max,
          backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
          color: count >= max ? AppColors.heartRed : AppColors.offlineBlue,
          minHeight: 6,
        ),
      ),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  const _EmptyState({required this.icon, required this.title,
      required this.subtitle, required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 44,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(
          fontFamily: 'Cormorant', fontSize: 22, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
        ), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(
          fontFamily: 'Jost', fontSize: 13,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
        ), textAlign: TextAlign.center),
      ]),
    ),
  );
}
