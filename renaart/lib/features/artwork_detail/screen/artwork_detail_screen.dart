import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/artwork_model.dart';
import '../../home/providers/app_providers.dart';
import '../../home/widgets/artwork_card.dart';

class ArtworkDetailScreen extends ConsumerWidget {
  final String artworkId;
  final Artwork? preloadedArtwork;

  const ArtworkDetailScreen({
    super.key,
    required this.artworkId,
    this.preloadedArtwork,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use preloaded data immediately, fetch full data in background
    final artworkAsync = ref.watch(artworkDetailProvider(artworkId));
    final artwork = artworkAsync.valueOrNull ?? preloadedArtwork;

    if (artwork == null && artworkAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 1.5,
          color: AppColors.sienna)),
      );
    }
    if (artwork == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Artwork not found',
          style: TextStyle(fontFamily: 'Jost'))),
      );
    }

    // Record view
    final user = ref.read(authProvider);
    if (user != null) {
      ref.read(storageProvider).recordView(artworkId, user.userId);
    }

    return _DetailBody(artwork: artwork);
  }
}

class _DetailBody extends ConsumerWidget {
  final Artwork artwork;
  const _DetailBody({required this.artwork});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(
      favoritesProvider.select((ids) => ids.contains(artwork.id)));
    final isOffline = ref.watch(
      offlineIdsProvider.select((ids) => ids.contains(artwork.id)));
    final offlineFull = ref.watch(
      offlineIdsProvider.select((ids) =>
          ids.length >= AppConstants.maxOfflineArtworks && !ids.contains(artwork.id)));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider);

    // Related artworks (same period, from cache)
    final allCached = ref.watch(storageProvider).getAllCachedArtworks();
    final related = allCached
        .where((a) => a.id != artwork.id && a.period == artwork.period)
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: CustomScrollView(slivers: [
        // ─── Hero Image AppBar ─────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => ref.read(favoritesProvider.notifier).toggle(
                artwork.id, user?.userId ?? 'guest'),
              child: Container(
                margin: const EdgeInsets.all(8),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? AppColors.heartRed : Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: artwork.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: artwork.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: isDark ? AppColors.darkCard : AppColors.parchmentDark,
                    ),
                    errorWidget: (_, __, ___) => _ImagePlaceholder(isDark: isDark),
                  )
                : _ImagePlaceholder(isDark: isDark),
          ),
        ),
        // ─── Content ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Period tag
              _Tag(label: artwork.period,
                color: isDark ? AppColors.goldLight : AppColors.sienna,
                bg: isDark ? AppColors.tagBgDark : AppColors.tagBg),
              const SizedBox(height: 10),
              // Title
              Text(artwork.title, style: TextStyle(
                fontFamily: 'Cormorant', fontSize: 32,
                fontWeight: FontWeight.w600, height: 1.1,
                color: isDark ? AppColors.darkText : AppColors.inkDark,
              )),
              const SizedBox(height: 4),
              Text(artwork.artist, style: TextStyle(
                fontFamily: 'Jost', fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.inkLight,
              )),
              const SizedBox(height: 16),
              // Action Buttons
              Row(children: [
                _ActionButton(
                  icon: isFav ? Icons.favorite : Icons.favorite_border,
                  label: isFav ? 'Liked' : 'Like',
                  color: isFav ? AppColors.heartRed : null,
                  isDark: isDark,
                  onTap: () => ref.read(favoritesProvider.notifier).toggle(
                    artwork.id, user?.userId ?? 'guest'),
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  icon: isOffline ? Icons.download_done : Icons.download_outlined,
                  label: isOffline
                      ? 'Saved Offline'
                      : offlineFull
                          ? 'Storage Full'
                          : 'Save Offline',
                  color: isOffline ? AppColors.offlineBlue : null,
                  isDark: isDark,
                  onTap: () {
                    final ok = ref.read(offlineIdsProvider.notifier)
                        .toggleOffline(artwork);
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppStrings.offlineStorageFull,
                          style: const TextStyle(fontFamily: 'Jost')),
                        backgroundColor: AppColors.sienna,
                        duration: const Duration(seconds: 3),
                      ));
                    }
                  },
                ),
              ]),
              const SizedBox(height: 14),
              // Metadata chips
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (artwork.medium.isNotEmpty)
                  _InfoChip(Icons.brush_outlined, artwork.medium, isDark),
                if (artwork.year.isNotEmpty)
                  _InfoChip(Icons.calendar_today_outlined, artwork.year, isDark),
                if (artwork.dimensions.isNotEmpty)
                  _InfoChip(Icons.straighten_outlined, artwork.dimensions, isDark),
                if (artwork.location.isNotEmpty)
                  _InfoChip(Icons.location_on_outlined, artwork.location, isDark),
              ]),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
              // Historical Background
              if (artwork.description.isNotEmpty) ...[
                Text('Historical Background', style: TextStyle(
                  fontFamily: 'Cormorant', fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.inkDark,
                )),
                const SizedBox(height: 10),
                Text(artwork.description, style: TextStyle(
                  fontFamily: 'Jost', fontSize: 14, height: 1.7,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
                )),
                if (artwork.historicalContext.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(artwork.historicalContext, style: TextStyle(
                    fontFamily: 'Jost', fontSize: 14, height: 1.7,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
                  )),
                ],
                const SizedBox(height: 20),
              ],
              // Meaning & Symbols
              if (artwork.meaning.isNotEmpty) ...[
                Text('Meaning & Symbols', style: TextStyle(
                  fontFamily: 'Cormorant', fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.inkDark,
                )),
                const SizedBox(height: 10),
                Text(artwork.meaning, style: TextStyle(
                  fontFamily: 'Jost', fontSize: 14, height: 1.7,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
                )),
                const SizedBox(height: 12),
              ],
              // Key Symbols
              if (artwork.keySymbols.isNotEmpty) ...[
                Wrap(spacing: 6, runSpacing: 6,
                  children: artwork.keySymbols.map((s) =>
                    _InfoChip(Icons.label_outline, s, isDark)).toList()),
                const SizedBox(height: 20),
              ],
              // Object ID
              Text('Object ID · ${artwork.id}', style: TextStyle(
                fontFamily: 'Jost', fontSize: 11,
                color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
              )),
              // Related Artworks
              if (related.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('More to Explore', style: TextStyle(
                  fontFamily: 'Cormorant', fontSize: 22,
                  fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.darkText : AppColors.inkDark,
                )),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: related.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SizedBox(
                      width: 130,
                      child: ArtworkCard(artwork: related[i]),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool isDark;
  const _ImagePlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    color: isDark ? AppColors.darkCard : AppColors.parchmentDark,
    child: Center(child: Icon(Icons.image_not_supported_outlined,
      color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint, size: 40)),
  );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Tag({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label.toUpperCase(), style: TextStyle(
      fontFamily: 'Jost', fontSize: 10, letterSpacing: 1.5,
      fontWeight: FontWeight.w500, color: color,
    )),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isDark;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label,
      this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = color != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? color!.withOpacity(0.1)
              : isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? color!.withOpacity(0.3)
                : isDark ? AppColors.darkBorder : AppColors.divider,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16,
              color: color ?? (isDark ? AppColors.darkTextFaint : AppColors.inkFaint)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontFamily: 'Jost', fontSize: 13, fontWeight: FontWeight.w500,
            color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.inkMedium),
          )),
        ]),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _InfoChip(this.icon, this.text, this.isDark);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: isDark ? AppColors.tagBgDark : AppColors.tagBg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(
        fontFamily: 'Jost', fontSize: 12,
        color: isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
      )),
    ]),
  );
}
