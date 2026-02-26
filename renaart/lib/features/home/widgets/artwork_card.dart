import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../models/artwork_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../home/providers/app_providers.dart';

class ArtworkCard extends ConsumerWidget {
  final Artwork artwork;
  final bool showOverlay;

  const ArtworkCard({
    super.key,
    required this.artwork,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(artwork.id)),
    );
    final isOffline = ref.watch(
      offlineProvider.select((ids) => ids.contains(artwork.id)),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push(
        RouteNames.artworkDetailPath(artwork.id),
        extra: artwork,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: artwork.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => _shimmer(isDark),
                  errorWidget: (context, url, error) => _placeholder(isDark),
                ),
                if (showOverlay) ...[
                  // Period tag
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _PeriodTag(period: artwork.period),
                  ),
                  // Offline badge
                  if (isOffline)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _OfflineBadge(),
                    ),
                  // Heart button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _HeartButton(
                      artworkId: artwork.id,
                      isFavorite: isFavorite,
                    ),
                  ),
                ],
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 13,
                      fontFamily: 'Cormorant',
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${artwork.artist} · ${artwork.year}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer(bool isDark) => Shimmer.fromColors(
    baseColor: isDark ? const Color(0xFF2A2218) : const Color(0xFFEDE5D0),
    highlightColor: isDark ? const Color(0xFF3A3228) : const Color(0xFFF5F0E8),
    child: Container(
      height: 160,
      color: isDark ? AppColors.darkCard : AppColors.parchmentDark,
    ),
  );

  Widget _placeholder(bool isDark) => Container(
    height: 160,
    color: isDark ? AppColors.darkCard : AppColors.parchmentDark,
    child: const Center(
      child: Icon(Icons.image_not_supported_outlined, color: AppColors.inkFaint),
    ),
  );
}

class _PeriodTag extends StatelessWidget {
  final String period;
  const _PeriodTag({required this.period});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        period,
        style: TextStyle(
          fontFamily: 'Jost',
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.goldLight : AppColors.sienna,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _OfflineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.offlineBlue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download_done, size: 10, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'Offline',
            style: TextStyle(
              fontFamily: 'Jost',
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartButton extends ConsumerWidget {
  final String artworkId;
  final bool isFavorite;

  const _HeartButton({required this.artworkId, required this.isFavorite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(favoritesProvider.notifier).toggle(artworkId),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: isFavorite ? AppColors.heartRed : AppColors.inkFaint,
        ),
      ),
    );
  }
}
