// Animated artwork mosaic background used on login and register screens.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

/// A decorative background showing a grid of faint artwork thumbnails
/// at the top, fading into the solid background color at the bottom.
class ArtMosaicBackground extends ConsumerWidget {
  final bool isDark;
  const ArtMosaicBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = isDark ? AppColors.darkCanvas : AppColors.canvas;

    // Get artwork URLs from cache
    final cached = ref.watch(storageProvider).getAllCachedArtworks();
    final urls = cached
        .where((a) => a.thumbnailUrl.isNotEmpty && a.id.startsWith('local_'))
        .take(12)
        .map((a) => a.thumbnailUrl)
        .toList();

    if (urls.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 0, left: 0, right: 0,
      height: 300,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: Opacity(
          opacity: isDark ? 0.18 : 0.14,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            padding: const EdgeInsets.all(4),
            itemCount: urls.length,
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: urls[i],
                fit: BoxFit.cover,
                httpHeaders: const {'User-Agent': 'RenaArtApp/1.0 (Flutter; educational)'},
                placeholder: (_, __) => Container(color: bg.withValues(alpha: 0.3)),
                errorWidget: (_, __, ___) => Container(color: bg.withValues(alpha: 0.3)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
