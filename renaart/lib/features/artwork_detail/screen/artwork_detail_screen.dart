import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/artwork_model.dart';
import '../../../models/mock_data.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/app_providers.dart';
import '../../home/widgets/artwork_card.dart';

class ArtworkDetailScreen extends ConsumerWidget {
  final String artworkId;
  final Artwork? artwork;

  const ArtworkDetailScreen({
    super.key,
    required this.artworkId,
    this.artwork,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = artwork ??
        MockData.artworks.firstWhere(
          (x) => x.id == artworkId,
          orElse: () => MockData.artworks.first,
        );
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(a.id)),
    );
    final isOffline = ref.watch(
      offlineProvider.select((ids) => ids.contains(a.id)),
    );
    final offlineFull = ref.watch(
      offlineProvider.select((ids) =>
          ids.length >= AppConstants.maxOfflineArtworks && !ids.contains(a.id)),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final related = MockData.getRelated(a);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: CustomScrollView(
        slivers: [
          // Hero image header
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
                onTap: () => ref.read(favoritesProvider.notifier).toggle(a.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.heartRed : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: a.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: isDark ? AppColors.darkCard : AppColors.parchmentDark,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: isDark ? AppColors.darkCard : AppColors.parchmentDark,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.inkFaint,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.tagBgDark
                          : AppColors.tagBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a.period.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.goldLight : AppColors.sienna,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    a.title,
                    style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.inkDark,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.artist,
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 15,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.inkLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      _ActionButton(
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        label: isFavorite ? 'Liked' : 'Like',
                        color: isFavorite ? AppColors.heartRed : null,
                        onTap: () =>
                            ref.read(favoritesProvider.notifier).toggle(a.id),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _ActionButton(
                        icon: isOffline
                            ? Icons.download_done
                            : Icons.download_outlined,
                        label: isOffline ? 'Saved Offline' : 'Save Offline',
                        color: isOffline ? AppColors.offlineBlue : null,
                        onTap: () {
                          final ok = ref
                              .read(offlineProvider.notifier)
                              .saveOffline(a.id);
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Storage full (${AppConstants.maxOfflineArtworks}/${AppConstants.maxOfflineArtworks}). Remove an artwork first.',
                                  style: const TextStyle(fontFamily: 'Jost'),
                                ),
                                backgroundColor: AppColors.sienna,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (a.medium.isNotEmpty) _Tag(a.medium, isDark, Icons.brush_outlined),
                      if (a.department.isNotEmpty) _Tag(a.department, isDark, Icons.museum_outlined),
                      if (a.year.isNotEmpty) _Tag(a.year, isDark, Icons.calendar_today_outlined),
                      if (a.dimensions != null) _Tag(a.dimensions!, isDark, Icons.straighten_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  // Historical Background
                  Text(
                    'Historical Background',
                    style: TextStyle(
                      fontFamily: 'Cormorant',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.inkDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    a.description,
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 14,
                      height: 1.7,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.inkMedium,
                    ),
                  ),
                  if (a.historicalContext != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      a.historicalContext!,
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 14,
                        height: 1.7,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.inkMedium,
                      ),
                    ),
                  ],
                  if (a.meaning != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Meaning & Symbols',
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      a.meaning!,
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 14,
                        height: 1.7,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.inkMedium,
                      ),
                    ),
                  ],
                  if (a.keySymbols.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: a.keySymbols
                          .map((s) => _Tag(s, isDark, null))
                          .toList(),
                    ),
                  ],
                  if (a.location != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'About the Artist',
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${a.artist} — ${a.period} period.\nCurrently housed at ${a.location}.',
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 14,
                        height: 1.7,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.inkMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Object ID · ${a.id}',
                    style: TextStyle(
                      fontFamily: 'Jost',
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextFaint
                          : AppColors.inkFaint,
                    ),
                  ),
                  if (related.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'More to Explore',
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkText : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: related.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) => SizedBox(
                          width: 130,
                          child: ArtworkCard(artwork: related[i]),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = color != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? color!.withOpacity(0.1)
              : isDark
                  ? AppColors.darkCard
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? color!.withOpacity(0.3)
                : isDark
                    ? AppColors.darkBorder
                    : AppColors.dividerLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color ?? AppColors.inkFaint),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.inkMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool isDark;
  final IconData? icon;

  const _Tag(this.text, this.isDark, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.tagBgDark : AppColors.tagBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Jost',
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
            ),
          ),
        ],
      ),
    );
  }
}
