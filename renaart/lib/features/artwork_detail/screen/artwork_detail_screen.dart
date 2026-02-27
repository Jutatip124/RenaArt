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
  const ArtworkDetailScreen({super.key, required this.artworkId, this.preloadedArtwork});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artworkAsync = ref.watch(artworkDetailProvider(artworkId));
    final artwork = artworkAsync.valueOrNull ?? preloadedArtwork;
    final user = ref.read(authProvider);
    if (user != null) { ref.read(storageProvider).recordView(artworkId, user.userId); }
    if (artwork == null && artworkAsync.isLoading) {
      return Scaffold(
          body: Center(child: CircularProgressIndicator(strokeWidth: 1.5,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.gold : AppColors.ink)));
    }
    if (artwork == null) {
      return Scaffold(appBar: AppBar(),
          body: const Center(child: Text('Not found', style: TextStyle(fontFamily: 'Jost'))));
    }
    return _Body(artwork: artwork);
  }
}

class _Body extends ConsumerWidget {
  final Artwork artwork;
  const _Body({required this.artwork});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav      = ref.watch(favoritesProvider.select((l) => l.contains(artwork.id)));
    final isOffline  = ref.watch(offlineIdsProvider.select((l) => l.contains(artwork.id)));
    final offlineFull= ref.watch(offlineIdsProvider.select((l) =>
        l.length >= AppConstants.maxOfflineArtworks && !l.contains(artwork.id)));
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final user       = ref.watch(authProvider);
    final bg         = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final text       = isDark ? AppColors.darkText   : AppColors.ink;
    final sub        = isDark ? AppColors.darkSub    : AppColors.inkMid;
    final faint      = isDark ? AppColors.darkFaint  : AppColors.inkLight;

    final cached  = ref.watch(storageProvider).getAllCachedArtworks();
    final related = cached.where((a) => a.id != artwork.id && a.period == artwork.period)
        .take(4).toList();

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(slivers: [
        // ── Hero Image ──────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 320, pinned: true,
          backgroundColor: bg,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: Container(margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // Glass pill button — Museum style
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18)),
          ),
          actions: [
            GestureDetector(
              onTap: () => ref.read(favoritesProvider.notifier)
                  .toggle(artwork.id, user?.userId ?? 'guest'),
              child: Container(
                margin: const EdgeInsets.all(8), width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
                child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.heartRed : Colors.white, size: 16),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              // Image
              artwork.imageUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: artwork.imageUrl,
                      fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                      placeholder: (_, __) => Container(color: isDark
                          ? AppColors.darkCard : AppColors.canvasTone),
                      errorWidget: (_, __, ___) => Container(
                          color: isDark ? AppColors.darkCard : AppColors.canvasTone,
                          child: Center(child: Icon(Icons.image_outlined,
                              color: faint, size: 36))))
                  : Container(color: isDark ? AppColors.darkCard : AppColors.canvasTone),
              // Bottom gradient — darker/stronger in dark mode (cinematic)
              Positioned(bottom: 0, left: 0, right: 0,
                child: Container(height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [
                        (isDark ? AppColors.darkCanvas : AppColors.canvas).withValues(alpha: 0.95),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
        // ── Content ─────────────────────────────────────────────────
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Period label (small caps, museum style)
            Text(artwork.period.toUpperCase(),
              style: TextStyle(fontFamily: 'Jost', fontSize: 10,
                  fontWeight: FontWeight.w600, letterSpacing: 1.8,
                  color: isDark ? AppColors.gold : AppColors.accentWarm)),
            const SizedBox(height: 6),
            // Artwork title — large Cormorant
            Text(artwork.title,
              style: TextStyle(fontFamily: 'Cormorant', fontSize: 32,
                  fontWeight: FontWeight.w700, color: text,
                  letterSpacing: -0.8, height: 1.05)),
            const SizedBox(height: 6),
            Text(artwork.artist,
              style: TextStyle(fontFamily: 'Jost', fontSize: 15,
                  fontWeight: FontWeight.w300, color: sub)),
            if (artwork.year.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(artwork.year,
                style: TextStyle(fontFamily: 'Jost', fontSize: 12,
                    color: isDark ? AppColors.gold : AppColors.inkLight,
                    letterSpacing: 0.3)),
            ],
            const SizedBox(height: 18),
            // Action buttons — inline pill style
            Row(children: [
              _ActionPill(
                icon: isFav ? Icons.favorite : Icons.favorite_border,
                label: isFav ? 'Liked' : 'Like',
                active: isFav, activeColor: AppColors.heartRed,
                isDark: isDark,
                onTap: () => ref.read(favoritesProvider.notifier)
                    .toggle(artwork.id, user?.userId ?? 'guest'),
              ),
              const SizedBox(width: 8),
              _ActionPill(
                icon: isOffline ? Icons.download_done : Icons.download_outlined,
                label: isOffline ? 'Saved' : (offlineFull ? 'Full' : 'Save Offline'),
                active: isOffline, activeColor: AppColors.saveBlue,
                isDark: isDark,
                onTap: () {
                  final ok = ref.read(offlineIdsProvider.notifier).toggleOffline(artwork);
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(AppStrings.offlineStorageFull,
                          style: TextStyle(fontFamily: 'Jost')),
                      backgroundColor: isDark ? AppColors.darkRaised : AppColors.ink,
                      duration: const Duration(seconds: 3)));
                  }
                },
              ),
            ]),
            const SizedBox(height: 20),
            // Metadata — thin horizontal chips
            Wrap(spacing: 6, runSpacing: 6, children: [
              if (artwork.medium.isNotEmpty)    _MetaChip(artwork.medium, isDark),
              if (artwork.dimensions.isNotEmpty) _MetaChip(artwork.dimensions, isDark),
              if (artwork.location.isNotEmpty)   _MetaChip(artwork.location, isDark),
            ]),
            const SizedBox(height: 24),
            Divider(color: isDark ? AppColors.darkBorder : AppColors.inkHair, thickness: 0.8),
            const SizedBox(height: 22),
            // Historical Background
            if (artwork.description.isNotEmpty) ...[
              _SectionTitle('Historical Background', isDark),
              const SizedBox(height: 10),
              Text(artwork.description, style: TextStyle(fontFamily: 'Jost',
                  fontSize: 14, height: 1.7, fontWeight: FontWeight.w300, color: sub)),
              const SizedBox(height: 18),
            ],
            if (artwork.meaning.isNotEmpty) ...[
              _SectionTitle('Meaning & Symbols', isDark),
              const SizedBox(height: 10),
              Text(artwork.meaning, style: TextStyle(fontFamily: 'Jost',
                  fontSize: 14, height: 1.7, fontWeight: FontWeight.w300, color: sub)),
              const SizedBox(height: 12),
            ],
            if (artwork.keySymbols.isNotEmpty) ...[
              Wrap(spacing: 6, runSpacing: 6,
                children: artwork.keySymbols.map((s) => _MetaChip(s, isDark)).toList()),
              const SizedBox(height: 18),
            ],
            // Object ID footnote
            Text('Object ID · ${artwork.id}', style: TextStyle(fontFamily: 'Jost',
                fontSize: 10, color: faint, letterSpacing: 0.3)),
            // Related artworks
            if (related.isNotEmpty) ...[
              const SizedBox(height: 30),
              _SectionTitle('More to Explore', isDark),
              const SizedBox(height: 14),
              SizedBox(height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: related.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => SizedBox(width: 130,
                      child: ArtworkCard(artwork: related[i])),
                ),
              ),
            ],
            const SizedBox(height: 36),
          ]),
        )),
      ]),
    );
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text; final bool isDark;
  const _SectionTitle(this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(fontFamily: 'Cormorant', fontSize: 22,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkText : AppColors.ink));
}

class _ActionPill extends StatelessWidget {
  final IconData icon; final String label;
  final bool active; final Color activeColor;
  final bool isDark; final VoidCallback onTap;
  const _ActionPill({required this.icon, required this.label, required this.active,
      required this.activeColor, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? activeColor.withValues(alpha: 0.12)
            : (isDark ? AppColors.darkCard : AppColors.canvasCard),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active ? activeColor.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.inkHair),
          width: 0.8,
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15,
            color: active ? activeColor
                : (isDark ? AppColors.darkFaint : AppColors.inkLight)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontFamily: 'Jost', fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? activeColor
                : (isDark ? AppColors.darkSub : AppColors.inkMid))),
      ]),
    ),
  );
}

class _MetaChip extends StatelessWidget {
  final String text; final bool isDark;
  const _MetaChip(this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkRaised : AppColors.canvasTone,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.inkHair, width: 0.5),
    ),
    child: Text(text, style: TextStyle(fontFamily: 'Jost', fontSize: 11,
        color: isDark ? AppColors.darkSub : AppColors.inkMid)),
  );
}
