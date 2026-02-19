import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renaart/core/theme/app_theme.dart';
import 'package:renaart/models/artwork.dart';
import 'package:renaart/services/providers.dart';

class ArtworkDetailScreen extends ConsumerWidget {
  final String objectId;
  const ArtworkDetailScreen({super.key, required this.objectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artworkAsync = ref.watch(artworkDetailProvider(objectId));
    final isFav = ref.watch(favoritesProvider
        .select((_) => ref.read(favoritesProvider.notifier).isFavorited(objectId)));
    final isOffline = ref.watch(offlineProvider
        .select((_) => ref.read(offlineProvider.notifier).isOfflineSaved(objectId)));
    final offlineFull = ref.watch(offlineProvider
        .select((_) => ref.read(offlineProvider.notifier).isFull));

    return Scaffold(
      body: artworkAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.sienna)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (artwork) {
          if (artwork == null) {
            return const Center(child: Text('Artwork not found.'));
          }
          return _DetailBody(
            artwork: artwork,
            isFav: isFav,
            isOffline: isOffline,
            offlineFull: offlineFull,
          );
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final Artwork artwork;
  final bool isFav;
  final bool isOffline;
  final bool offlineFull;

  const _DetailBody({
    required this.artwork,
    required this.isFav,
    required this.isOffline,
    required this.offlineFull,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // ── Hero Image + Back / Share ─────────────────────────
        SliverAppBar(
          expandedHeight: 340,
          pinned: true,
          backgroundColor: AppColors.ink,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: AppColors.cream.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.ink, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppColors.cream.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined,
                      color: AppColors.ink, size: 18),
                  onPressed: () {},
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: artwork.imageUrl ?? artwork.thumbnailUrl ?? '',
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: AppColors.parchment,
                child: const Icon(Icons.broken_image_outlined,
                    size: 64, color: AppColors.stone),
              ),
            ),
          ),
        ),

        // ── Content ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period label
                if (artwork.period?.isNotEmpty == true)
                  Text(
                    (artwork.period ?? '').toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: AppColors.gold,
                          letterSpacing: 1.5,
                        ),
                  ),
                const SizedBox(height: 6),

                // Title
                Text(
                  artwork.title,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 4),

                // Artist
                Text(
                  artwork.artistName,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.stone,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 20),

                // ── Action Buttons ────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(favoritesProvider.notifier).toggle(artwork),
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                        ),
                        label: Text(isFav ? 'Liked' : 'Like'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFav ? AppColors.sienna : AppColors.parchment,
                          foregroundColor:
                              isFav ? Colors.white : AppColors.sienna,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isOffline
                            ? null
                            : () async {
                                if (offlineFull) {
                                  _showOfflineFullDialog(context, ref);
                                  return;
                                }
                                final ok = await ref
                                    .read(offlineProvider.notifier)
                                    .saveOffline(artwork);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(ok
                                          ? '✓ Saved for offline viewing'
                                          : 'Offline storage full (10/10)'),
                                      backgroundColor:
                                          ok ? AppColors.sienna : AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                        icon: Icon(
                          isOffline ? Icons.bookmark : Icons.bookmark_border,
                          size: 18,
                        ),
                        label: Text(isOffline ? 'Saved' : 'Save Offline'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isOffline ? AppColors.gold : AppColors.parchment,
                          foregroundColor:
                              isOffline ? AppColors.ink : AppColors.gold,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Info Chips ────────────────────────────────
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (artwork.medium?.isNotEmpty == true)
                      _InfoChip('🖌 ${artwork.medium}'),
                    if (artwork.department?.isNotEmpty == true)
                      _InfoChip('📍 ${artwork.department}'),
                    if (artwork.objectDate.isNotEmpty)
                      _InfoChip('📅 ${artwork.objectDate}'),
                    if (artwork.dimensions?.isNotEmpty == true)
                      _InfoChip(artwork.dimensions!),
                  ],
                ),

                // ── Historical Background ─────────────────────
                _SectionTitle('Historical Background'),
                Text(
                  artwork.creditLine?.isNotEmpty == true
                      ? '${artwork.creditLine}'
                      : 'This work belongs to the ${artwork.department ?? 'European'} collection '
                          'and dates to ${artwork.objectDate}. '
                          '${artwork.culture?.isNotEmpty == true ? 'Culture: ${artwork.culture}.' : ''} '
                          'It is one of the remarkable examples from the Renaissance period held in the '
                          'Metropolitan Museum of Art collection.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        height: 1.75,
                      ),
                ),

                // ── Artist Info ───────────────────────────────
                _SectionTitle('About the Artist'),
                Text(
                  artwork.artistBio?.isNotEmpty == true
                      ? artwork.artistBio!
                      : '${artwork.artistName} was one of the defining artists of the Renaissance period. '
                          'Their contribution to art, form, and expression helped shape the visual language of Western civilization.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        height: 1.75,
                      ),
                ),

                // ── Accession ─────────────────────────────────
                if (artwork.accessionYear?.isNotEmpty == true) ...[
                  const SizedBox(height: 24),
                  Divider(color: AppColors.parchment),
                  const SizedBox(height: 12),
                  Text(
                    'Entered the collection in ${artwork.accessionYear} · Object ID ${artwork.objectId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showOfflineFullDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Offline Storage Full',
          style: GoogleFonts.cormorantGaramond(fontSize: 20),
        ),
        content: const Text(
          'You have saved 10 artworks offline (maximum). '
          'Remove one from your Collection to save a new one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  const _InfoChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
