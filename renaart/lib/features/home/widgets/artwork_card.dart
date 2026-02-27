import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../models/artwork_model.dart';
import '../../home/providers/app_providers.dart';

// ArtworkCard — dual-mode Arts Gallery card
// Light: white card, hairline border, serif title, warm caption
// Dark:  charcoal card, gradient scrim, gold year accent, cinematic
class ArtworkCard extends ConsumerWidget {
  final Artwork artwork;
  const ArtworkCard({super.key, required this.artwork});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav     = ref.watch(favoritesProvider.select((l) => l.contains(artwork.id)));
    final isOffline = ref.watch(offlineIdsProvider.select((l) => l.contains(artwork.id)));
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final user      = ref.watch(authProvider);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.artworkPath(artwork.id), extra: artwork),
      child: Container(
        decoration: BoxDecoration(
          color:             isDark ? AppColors.darkCard : AppColors.canvasCard,
          borderRadius:      BorderRadius.circular(8),
          border:            Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.inkHair,
            width: isDark ? 0.5 : 0.8,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          // ── Image ──────────────────────────────────────────────────
          Stack(children: [
            CachedNetworkImage(
              imageUrl:    artwork.thumbnailUrl,
              fit:         BoxFit.cover,
              width:       double.infinity,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor:      isDark ? AppColors.darkRaised : AppColors.canvasTone,
                highlightColor: isDark ? AppColors.darkCard   : AppColors.canvasCard,
                child: Container(height: 150, color: AppColors.canvasTone),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 130,
                color: isDark ? AppColors.darkRaised : AppColors.canvasTone,
                child: Center(child: Icon(Icons.image_outlined,
                    color: isDark ? AppColors.darkFaint : AppColors.inkLight, size: 26)),
              ),
            ),
            // Dark mode: bottom gradient scrim
            if (isDark)
              Positioned(bottom: 0, left: 0, right: 0,
                child: Container(height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [AppColors.darkCard.withValues(alpha: 0.75), Colors.transparent]),
                  ),
                ),
              ),
            // Heart button
            Positioned(top: 8, right: 8,
              child: _HeartBtn(
                isFav: isFav, isDark: isDark,
                onTap: () => ref.read(favoritesProvider.notifier)
                    .toggle(artwork.id, user?.userId ?? 'guest'),
              ),
            ),
            // Offline indicator — thin gold line (dark) or blue dot (light)
            if (isOffline && isDark)
              Positioned(top: 0, left: 0, right: 0,
                child: Container(height: 2, color: AppColors.gold)),
            if (isOffline && !isDark)
              Positioned(top: 10, left: 10,
                child: Container(width: 7, height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.saveBlue, shape: BoxShape.circle))),
          ]),
          // ── Info ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 9, 11, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(artwork.title,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cormorant', fontSize: 14, fontWeight: FontWeight.w600,
                  height: 1.15, letterSpacing: 0.1,
                  color: isDark ? AppColors.darkText : AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(artwork.artist,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Jost', fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: isDark ? AppColors.darkSub : AppColors.inkMid),
              ),
              if (artwork.year.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(artwork.year,
                  style: TextStyle(fontFamily: 'Jost', fontSize: 10,
                      letterSpacing: 0.4,
                      color: isDark ? AppColors.gold : AppColors.inkLight),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _HeartBtn extends StatelessWidget {
  final bool isFav;
  final bool isDark;
  final VoidCallback onTap;
  const _HeartBtn({required this.isFav, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkRaised.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        size: 15,
        color: isFav ? AppColors.heartRed
            : isDark ? AppColors.darkFaint : AppColors.inkLight,
      ),
    ),
  );
}
