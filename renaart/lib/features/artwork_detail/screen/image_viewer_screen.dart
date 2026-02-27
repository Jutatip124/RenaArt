import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen zoomable image viewer.
/// Shown when the user taps the hero image on the artwork detail page.
///
/// Features:
///   • InteractiveViewer — pinch-to-zoom (0.8× to 8×) and pan
///   • Back button (top-left glass pill)
///   • Fade-in bottom caption (title + artist)
///   • Status bar hidden while viewing
class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String artist;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.artist,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  bool _showCaption = true;

  @override
  void initState() {
    super.initState();
    // Hide status bar for immersive viewing
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    // Restore status bar on exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _toggleCaption() {
    setState(() => _showCaption = !_showCaption);
    if (_showCaption) {
      _fadeCtrl.forward();
    } else {
      _fadeCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleCaption,
        child: Stack(children: [
          // ── Zoomable image ────────────────────────────────────────
          SizedBox.expand(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 8.0,
              clipBehavior: Clip.none,
              child: Center(
                child: widget.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white24,
                          size: 52,
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white24,
                        size: 52,
                      ),
              ),
            ),
          ),

          // ── Back button (top-left) ────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom caption ────────────────────────────────────────
          if (widget.title.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 32, 22, 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.82),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: 'Cormorant',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                      ),
                      if (widget.artist.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.artist,
                          style: TextStyle(
                            fontFamily: 'Jost',
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Tap to toggle UI  ·  Pinch to zoom',
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
