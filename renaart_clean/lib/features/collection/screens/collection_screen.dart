import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renaart/core/theme/app_theme.dart';
import 'package:renaart/models/artwork.dart';
import 'package:renaart/services/providers.dart';
import 'package:renaart/services/storage_service.dart';
import 'package:renaart/shared/widgets/artwork_masonry_grid.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});
  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final offline = ref.watch(offlineProvider);
    final offlineCount = offline.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Text(
                    'My Renaissance',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.sort, color: AppColors.stone),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ── Tab Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabs,
                labelColor: AppColors.sienna,
                unselectedLabelColor: AppColors.stone,
                indicatorColor: AppColors.sienna,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: AppColors.parchment,
                tabs: [
                  Tab(text: '❤  Liked (${favorites.length})'),
                  Tab(text: '🔖 Saved Offline ($offlineCount/${StorageService.maxOfflineArtworks})'),
                ],
              ),
            ),

            // ── Offline Banner (shown on Offline tab) ────────────
            if (_tabs.index == 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _OfflineBanner(count: offlineCount),
              ),

            // ── Tab Views ────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  // Liked Tab
                  favorites.isEmpty
                      ? _EmptyState(
                          icon: Icons.favorite_border,
                          message:
                              'No liked artworks yet.\nTap ❤ on any artwork to add it here.',
                        )
                      : SingleChildScrollView(
                          child: ArtworkMasonryGrid(artworks: favorites),
                        ),

                  // Offline Tab
                  offline.isEmpty
                      ? _EmptyState(
                          icon: Icons.bookmark_border,
                          message:
                              'No artworks saved offline yet.\nTap "Save Offline" on any artwork.',
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              ArtworkMasonryGrid(artworks: offline),
                              _OfflineManageHint(artworks: offline),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final int count;
  const _OfflineBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final pct = count / StorageService.maxOfflineArtworks;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D1F0A), Color(0xFF5C2E0E)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark, color: AppColors.gold, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Offline Library',
                  style: TextStyle(
                    color: AppColors.cream,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.stone.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count of ${StorageService.maxOfflineArtworks} slots used',
                  style: const TextStyle(
                      color: Color(0x99F7F3ED), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$count/${StorageService.maxOfflineArtworks}',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cormorant Garamond',
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineManageHint extends ConsumerWidget {
  final List<Artwork> artworks;
  const _OfflineManageHint({required this.artworks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (artworks.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Text(
        'Long press any artwork to remove from offline',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.stone.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.stone),
            ),
          ],
        ),
      ),
    );
  }
}
