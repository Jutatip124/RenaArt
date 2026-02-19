import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:renaart/core/router/route_names.dart';
import 'package:renaart/core/theme/app_theme.dart';
import 'package:renaart/models/artwork.dart';
import 'package:renaart/services/providers.dart';
import 'package:shimmer/shimmer.dart';

class ArtworkCard extends ConsumerWidget {
  final Artwork artwork;
  final double? imageHeight;

  const ArtworkCard({
    super.key,
    required this.artwork,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider
        .select((_) => ref.read(favoritesProvider.notifier).isFavorited(artwork.objectId)));
    final isOffline = ref.watch(offlineProvider
        .select((_) => ref.read(offlineProvider.notifier).isOfflineSaved(artwork.objectId)));

    return GestureDetector(
      onTap: () => context.push(RouteNames.artworkDetailPath(artwork.objectId)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: AppColors.parchment,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──────────────────────────────────────────
              Stack(
                children: [
                  _buildImage(),
                  // Offline badge
                  if (isOffline)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bookmark,
                                size: 10, color: AppColors.ink),
                            const SizedBox(width: 3),
                            Text(
                              'Offline',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: AppColors.ink,
                                    fontSize: 10,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Heart button (top-right on tap-hold or visible always)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(favoritesProvider.notifier).toggle(artwork),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isFav
                              ? AppColors.sienna
                              : Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: isFav ? Colors.white : AppColors.sienna,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // ── Info ────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artwork.title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${artwork.artistName} · ${artwork.objectDate}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = artwork.thumbnailUrl ?? artwork.imageUrl ?? '';
    if (url.isEmpty) {
      return Container(
        height: imageHeight ?? 150,
        color: AppColors.parchment,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.stone),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: imageHeight,
      fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.parchment,
        highlightColor: AppColors.cream,
        child: Container(
          height: imageHeight ?? 140,
          color: AppColors.parchment,
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        height: imageHeight ?? 140,
        color: AppColors.parchment,
        child: const Icon(Icons.broken_image_outlined, color: AppColors.stone),
      ),
    );
  }
}
