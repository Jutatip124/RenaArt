import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../models/artwork_model.dart';
import '../../home/providers/app_providers.dart';

/// Week 5 Spec: Molecule component — ArtworkCard
/// Built following Atomic Design methodology
class ArtworkCard extends ConsumerWidget {
  final Artwork artwork;
  const ArtworkCard({super.key, required this.artwork});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(
      favoritesProvider.select((ids) => ids.contains(artwork.id)),
    );
    final isOffline = ref.watch(
      offlineIdsProvider.select((ids) => ids.contains(artwork.id)),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.artworkPath(artwork.id), extra: artwork),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.divider,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image area
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: artwork.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => _ShimmerBox(isDark: isDark),
                  errorWidget: (_, __, ___) => _ErrorBox(isDark: isDark),
                ),
                // Period tag (Atom)
                Positioned(
                  top: 8, left: 8,
                  child: _PeriodTag(period: artwork.period, isDark: isDark),
                ),
                // Offline badge
                if (isOffline)
                  Positioned(
                    top: 8, right: 8,
                    child: _OfflineBadge(),
                  ),
                // Heart button (Atom)
                Positioned(
                  bottom: 8, right: 8,
                  child: _HeartButton(artworkId: artwork.id, isFavorite: isFav),
                ),
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
                    style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.inkDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${artwork.artist}${artwork.year.isNotEmpty ? ' · ${artwork.year}' : ''}',
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
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
}

// ─── Atoms ────────────────────────────────────────────────────────────────────

class _PeriodTag extends StatelessWidget {
  final String period;
  final bool isDark;
  const _PeriodTag({required this.period, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: (isDark ? AppColors.darkCard : Colors.white).withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(period, style: TextStyle(
      fontFamily: 'Jost', fontSize: 9, fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      color: isDark ? AppColors.goldLight : AppColors.sienna,
    )),
  );
}

class _OfflineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.offlineBlue.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.download_done, size: 10, color: Colors.white),
        SizedBox(width: 3),
        Text('Offline', style: TextStyle(
          fontFamily: 'Jost', fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500,
        )),
      ],
    ),
  );
}

class _HeartButton extends ConsumerWidget {
  final String artworkId;
  final bool isFavorite;
  const _HeartButton({required this.artworkId, required this.isFavorite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    return GestureDetector(
      onTap: () => ref.read(favoritesProvider.notifier).toggle(
        artworkId, user?.userId ?? 'guest',
      ),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
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

class _ShimmerBox extends StatelessWidget {
  final bool isDark;
  const _ShimmerBox({required this.isDark});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: isDark ? const Color(0xFF2A2218) : const Color(0xFFEDE5D0),
    highlightColor: isDark ? const Color(0xFF3A3228) : const Color(0xFFF5F0E8),
    child: Container(
      height: 160,
      color: isDark ? AppColors.darkCard : AppColors.parchmentDark,
    ),
  );
}

class _ErrorBox extends StatelessWidget {
  final bool isDark;
  const _ErrorBox({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    height: 140,
    color: isDark ? AppColors.darkCard : AppColors.parchmentDark,
    child: Center(child: Icon(
      Icons.image_not_supported_outlined,
      color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
    )),
  );
}
