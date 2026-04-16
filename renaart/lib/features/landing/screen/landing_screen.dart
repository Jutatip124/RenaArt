
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static const double _topNavHeight = 88;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _selectedWorksKey = GlobalKey();
  final GlobalKey _ourVisionKey = GlobalKey();
  final GlobalKey _renaartAnywhereKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToSection(GlobalKey key) {
    final sectionContext = key.currentContext;
    if (sectionContext == null || !_scrollController.hasClients) {
      return;
    }
    final box = sectionContext.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }
    final position = box.localToGlobal(Offset.zero);
    final rawOffset = _scrollController.offset + position.dy - _topNavHeight - 12;
    final target = rawOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target.toDouble(),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = width >= 1100;
    final isTablet = width >= 760;
    final side = isDesktop ? 48.0 : (isTablet ? 28.0 : 16.0);

    const bg = Color(0xFF131313);
    const surfaceLow = Color(0xFF1C1B1B);
    const onSurface = Color(0xFFE5E2E1);
    const onSurfaceVariant = Color(0xFFD0C5AF);
    const gold = AppColors.gold;
    const outline = Color(0xFF4D4635);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 96),
            child: Column(
              children: [
                _HeroSection(
                  height: height,
                  side: side,
                  isDesktop: isDesktop,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  gold: gold,
                  onEnter: () => context.go(AppRoutes.splash),
                  onImageTap: () => _showImagePreviewDialog(
                    context,
                    _heroImage,
                    title: 'The Soul of the Renaissance',
                  ),
                ),
                KeyedSubtree(
                  key: _selectedWorksKey,
                  child: _MasterpieceSection(
                    side: side,
                    isDesktop: isDesktop,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                    gold: gold,
                  ),
                ),
                KeyedSubtree(
                  key: _ourVisionKey,
                  child: _JourneySection(
                    side: side,
                    isDesktop: isDesktop,
                    surfaceLow: surfaceLow,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                    gold: gold,
                    outline: outline,
                  ),
                ),
                KeyedSubtree(
                  key: _renaartAnywhereKey,
                  child: _MobileSection(
                    side: side,
                    isDesktop: isDesktop,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                    gold: gold,
                    outline: outline,
                    onEnter: () => context.go(AppRoutes.splash),
                  ),
                ),
                const _FooterSection(
                  onSurface: onSurface,
                ),
              ],
            ),
          ),
          _TopNav(
            side: side,
            gold: gold,
            onLogoTap: _scrollToTop,
            onSelectWorks: () => _scrollToSection(_selectedWorksKey),
            onOurVision: () => _scrollToSection(_ourVisionKey),
            onRenaartAnywhere: () => _scrollToSection(_renaartAnywhereKey),
            onVisit: () => context.go(AppRoutes.splash),
          ),
        ],
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  final double side;
  final Color gold;
  final VoidCallback onLogoTap;
  final VoidCallback onSelectWorks;
  final VoidCallback onOurVision;
  final VoidCallback onRenaartAnywhere;
  final VoidCallback onVisit;

  const _TopNav({
    required this.side,
    required this.gold,
    required this.onLogoTap,
    required this.onSelectWorks,
    required this.onOurVision,
    required this.onRenaartAnywhere,
    required this.onVisit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF090909).withValues(alpha: 0.72),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: side, vertical: 18),
          child: Row(
            children: [
              InkWell(
                onTap: onLogoTap,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          AppColors.gold,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          'assets/images/logo_dark.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'RenaArt',
                      style: TextStyle(
                        color: gold,
                        fontSize: 28,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cormorant',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TopNavLink(label: 'Highlights', onTap: onSelectWorks),
                      const SizedBox(width: 6),
                      _TopNavLink(label: 'Features', onTap: onOurVision),
                      const SizedBox(width: 6),
                      _TopNavLink(
                        label: 'Mobile App',
                        onTap: onRenaartAnywhere,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onVisit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: const Color(0xFF3C2F00),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Launch App',
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopNavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TopNavLink({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFE5E2E1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(
          fontFamily: 'Jost',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
      child: Text(label.toUpperCase()),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final double height;
  final double side;
  final bool isDesktop;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color gold;
  final VoidCallback onEnter;
  final VoidCallback onImageTap;

  const _HeroSection({
    required this.height,
    required this.side,
    required this.isDesktop,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.gold,
    required this.onEnter,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final mockupWidth =
        (screenWidth * 0.34).clamp(260.0, 480.0).toDouble();
    final mockupStackWidth = mockupWidth + (mockupWidth * 0.5);
    final backPhoneOffsetX = mockupWidth * 0.55;
    final backPhoneOffsetY = mockupWidth * 0.12;
    final textMaxWidth = isDesktop
        ? (screenWidth - (side * 2) - mockupStackWidth - 40)
            .clamp(320.0, 760.0)
            .toDouble()
        : 980.0;
    return SizedBox(
      height: height * (isDesktop ? 0.92 : 0.86),
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onImageTap,
              child: _buildAdaptiveImage(
                _heroImage,
                fit: BoxFit.cover,
                fallbackColor: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF131313),
                      Color(0xCC131313),
                      Color(0x55131313),
                      Color(0x00131313),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isDesktop)
            Positioned(
              top: 4,
              right: side,
              child: SizedBox(
                width: mockupStackWidth,
                height: mockupWidth * 2.1,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: backPhoneOffsetY,
                      right: backPhoneOffsetX,
                      child: Transform.rotate(
                        angle: -0.14,
                        child: _PhoneMockup(
                          imageUrl: _featureMockupDetail,
                          width: mockupWidth * 0.92,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _PhoneMockup(
                        imageUrl: _featureMockupMasterpieces,
                        width: mockupWidth,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: side),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: textMaxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Renaissance masterpieces,\n',
                          style: TextStyle(
                            color: onSurface,
                            fontFamily: 'Cormorant',
                            fontWeight: FontWeight.w700,
                            fontSize: isDesktop ? 82 : 48,
                            height: 1.07,
                          ),
                          children: [
                            TextSpan(
                              text: 'explained',
                              style: TextStyle(
                                color: gold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const TextSpan(text: ' for modern explorers.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton(
                            onPressed: onEnter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor: const Color(0xFF3C2F00),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'ENTER THE GALLERY',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Browse 300 curated artworks, learn the stories behind each piece, and save your favorites for offline access.',
                        style: TextStyle(
                          color: onSurfaceVariant,
                          fontFamily: 'Jost',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterpieceSection extends StatelessWidget {
  final double side;
  final bool isDesktop;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color gold;

  const _MasterpieceSection({
    required this.side,
    required this.isDesktop,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(side, 72, side, 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HIGHLIGHTS',
            style: TextStyle(
              color: gold,
              fontFamily: 'Jost',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '300 Curated Masterpieces',
                  style: TextStyle(
                    color: onSurface,
                    fontFamily: 'Cormorant',
                    fontSize: isDesktop ? 64 : 42,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
              ),
              if (isDesktop)
                SizedBox(
                  width: 360,
                  child: Text(
                    'Explore paintings, sculptures, and frescoes with rich context, symbolism, and provenance.',
                    style: TextStyle(
                      color: onSurfaceVariant,
                      fontFamily: 'Jost',
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
          if (!isDesktop) ...[
            const SizedBox(height: 10),
            Text(
              'Explore paintings, sculptures, and frescoes with rich context, symbolism, and provenance.',
              style: TextStyle(
                color: onSurfaceVariant,
                fontFamily: 'Jost',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (isDesktop) ...[
            const Row(
              children: [
                Expanded(
                  flex: 8,
                  child: _ArtCard(
                    title: 'Madonna of the Goldfinch',
                    subtitle: 'Raphael, 1506',
                    imageUrl: _artMainOne,
                    aspectRatio: 16 / 9,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: _ArtCard(
                    title: 'The Creation of Adam',
                    subtitle: 'Michelangelo, 1512',
                    imageUrl: _artSideOne,
                    aspectRatio: 4 / 5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _ArtCard(
                    title: 'Lady with an Ermine',
                    subtitle: 'Da Vinci, 1489',
                    imageUrl: _artSideTwo,
                    aspectRatio: 4 / 5,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 8,
                  child: _ArtCard(
                    title: 'The School of Athens',
                    subtitle: 'Raphael, 1511',
                    imageUrl: _artMainTwo,
                    aspectRatio: 16 / 9,
                  ),
                ),
              ],
            ),
          ] else ...[
            const _ArtCard(
              title: 'Madonna of the Goldfinch',
              subtitle: 'Raphael, 1506',
              imageUrl: _artMainOne,
              aspectRatio: 16 / 9,
            ),
            const SizedBox(height: 12),
            const _ArtCard(
              title: 'The Creation of Adam',
              subtitle: 'Michelangelo, 1512',
              imageUrl: _artSideOne,
              aspectRatio: 4 / 5,
            ),
            const SizedBox(height: 12),
            const _ArtCard(
              title: 'Lady with an Ermine',
              subtitle: 'Da Vinci, 1489',
              imageUrl: _artSideTwo,
              aspectRatio: 4 / 5,
            ),
            const SizedBox(height: 12),
            const _ArtCard(
              title: 'The School of Athens',
              subtitle: 'Raphael, 1511',
              imageUrl: _artMainTwo,
              aspectRatio: 16 / 9,
            ),
          ],
        ],
      ),
    );
  }
}

class _ArtCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double aspectRatio;

  const _ArtCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return _HoverTapScale(
      onTap: () =>
          _showImagePreviewDialog(context, imageUrl, title: '$title — $subtitle'),
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildAdaptiveImage(
                  imageUrl,
                  fit: BoxFit.cover,
                  fallbackColor: const Color(0xFF242424),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF131313).withValues(alpha: 0.4),
                        const Color(0xFF131313).withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE5E2E1),
                        fontFamily: 'Cormorant',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Jost',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
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
}

class _JourneySection extends StatelessWidget {
  final double side;
  final bool isDesktop;
  final Color surfaceLow;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color gold;
  final Color outline;

  const _JourneySection({
    required this.side,
    required this.isDesktop,
    required this.surfaceLow,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.gold,
    required this.outline,
  });

  @override
  Widget build(BuildContext context) {
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FEATURES',
          style: TextStyle(
            color: gold,
            fontFamily: 'Jost',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover, Understand, Collect',
          style: TextStyle(
            color: onSurface,
            fontFamily: 'Cormorant',
            fontSize: isDesktop ? 60 : 42,
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        Container(width: 54, height: 2, color: gold),
        const SizedBox(height: 16),
        Text(
          'Search by title, artist, period, medium, or subject with smart filters that surface exactly what you want to see.',
          style: TextStyle(
            color: onSurfaceVariant,
            fontFamily: 'Jost',
            fontSize: 15,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Dive into full artwork details, meaning & symbols, and related works—then zoom in fullscreen to study every brushstroke.',
          style: TextStyle(
            color: onSurfaceVariant,
            fontFamily: 'Jost',
            fontSize: 15,
            height: 1.65,
          ),
        ),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: outline.withValues(alpha: 0.4)),
          ),
          child: isDesktop
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PhoneMockup(
                      imageUrl: _featureMockupSearch,
                      width: 230,
                    ),
                    SizedBox(width: 20),
                    _PhoneMockup(
                      imageUrl: _featureMockupDetail,
                      width: 230,
                    ),
                  ],
                )
              : const Column(
                  children: [
                    _PhoneMockup(
                      imageUrl: _featureMockupSearch,
                      width: 220,
                    ),
                    SizedBox(height: 18),
                    _PhoneMockup(
                      imageUrl: _featureMockupDetail,
                      width: 220,
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: outline.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"Art is the queen of all sciences communicating knowledge to all generations."',
                style: TextStyle(
                  color: onSurface,
                  fontFamily: 'Cormorant',
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '— LEONARDO DA VINCI',
                style: TextStyle(
                  color: gold,
                  fontFamily: 'Jost',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: surfaceLow,
      padding: EdgeInsets.fromLTRB(side, 78, side, 92),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: left),
                const SizedBox(width: 34),
                Expanded(flex: 7, child: right),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                left,
                const SizedBox(height: 20),
                right,
              ],
            ),
    );
  }
}

class _MobileSection extends StatelessWidget {
  final double side;
  final bool isDesktop;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color gold;
  final Color outline;
  final VoidCallback onEnter;

  const _MobileSection({
    required this.side,
    required this.isDesktop,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.gold,
    required this.outline,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final mockupWidth = isDesktop ? 230.0 : 220.0;
    final mockups = Wrap(
      alignment: WrapAlignment.center,
      spacing: 18,
      runSpacing: 18,
      children: [
        _PhoneMockup(imageUrl: _mobileUiImage, width: mockupWidth),
        _PhoneMockup(imageUrl: _featureMockupCollection, width: mockupWidth),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(side, 72, side, 72),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: outline.withValues(alpha: 0.36)),
        ),
        child: Stack(
          children: [
            isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _MobileCopy(
                          onSurface: onSurface,
                          onSurfaceVariant: onSurfaceVariant,
                          gold: gold,
                          onEnter: onEnter,
                        ),
                      ),
                      const SizedBox(width: 34),
                      SizedBox(
                        width: 520,
                        child: Center(child: mockups),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MobileCopy(
                        onSurface: onSurface,
                        onSurfaceVariant: onSurfaceVariant,
                        gold: gold,
                        onEnter: onEnter,
                      ),
                      const SizedBox(height: 20),
                      Center(child: mockups),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _MobileCopy extends StatelessWidget {
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color gold;
  final VoidCallback onEnter;

  const _MobileCopy({
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.gold,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RENAART ANYWHERE',
          style: TextStyle(
            color: gold,
            fontFamily: 'Jost',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Built for Mobile Learning',
          style: TextStyle(
            color: onSurface,
            fontFamily: 'Cormorant',
            fontSize: 56,
            fontWeight: FontWeight.w700,
            height: 1.04,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Save favorites to My Collection, access up to 10 works offline, and sync across devices with Firebase sign-in.',
          style: TextStyle(
            color: onSurfaceVariant,
            fontFamily: 'Jost',
            fontSize: 15,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            const _StoreButton(
              icon: Icons.apple,
              title: '',
              subtitle: 'Soon on the App Store',
              filled: true,
              onTap: null,
            ),
            _StoreButton(
              icon: Icons.play_arrow_rounded,
              title: 'Get it on',
              subtitle: 'Google Play',
              filled: false,
              onTap: onEnter,
            ),
          ],
        ),
      ],
    );
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool filled;
  final VoidCallback? onTap;

  const _StoreButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final textColor = filled ? const Color(0xFF131313) : const Color(0xFFE5E2E1);
    return Opacity(
      opacity: isEnabled ? 1 : 0.55,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: filled ? const Color(0xFFE5E2E1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled ? const Color(0xFFE5E2E1) : const Color(0xFF4D4635),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.72),
                        fontFamily: 'Jost',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'Jost',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  final String imageUrl;
  final double width;

  const _PhoneMockup({
    required this.imageUrl,
    this.width = 320,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 9 / 19,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: const Color(0xFF3A3939), width: 7),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: _buildAdaptiveImage(
              imageUrl,
              fit: BoxFit.cover,
              fallbackColor: const Color(0xFF242424),
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  final Color onSurface;

  const _FooterSection({
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D0D0D),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 44),
      child: Column(
        children: [
          Text(
            'RenaArt',
            style: TextStyle(
              color: onSurface,
              fontFamily: 'Cormorant',
              fontSize: 34,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 20,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink('Privacy Policy'),
              _FooterLink('Terms of Service'),
              _FooterLink('Press'),
              _FooterLink('Contact'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2026 The Digital Curator. All rights reserved.',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.48),
              fontFamily: 'Jost',
              fontSize: 11,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;

  const _FooterLink(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.52),
        fontFamily: 'Jost',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _HoverTapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const _HoverTapScale({
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<_HoverTapScale> createState() => _HoverTapScaleState();
}

class _HoverTapScaleState extends State<_HoverTapScale> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;
    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: isInteractive ? (_) => setState(() => _isHovered = true) : null,
      onExit: isInteractive ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedScale(
        scale: _isHovered && isInteractive ? 1.02 : 1,
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          decoration: widget.borderRadius == null || !_isHovered || !isInteractive
              ? null
              : BoxDecoration(
                  borderRadius: widget.borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.34),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: widget.borderRadius,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildAdaptiveImage(
  String imageUrl, {
  required BoxFit fit,
  double? width,
  double? height,
  Color fallbackColor = const Color(0xFF242424),
}) {
  final fallback = Container(
    color: fallbackColor,
    width: width,
    height: height,
  );

  if (imageUrl.startsWith('assets/')) {
    return Image.asset(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  return Image.network(
    imageUrl,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (_, __, ___) => fallback,
  );
}

void _showImagePreviewDialog(
  BuildContext context,
  String imageUrl, {
  String? title,
}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.9),
    builder: (context) {
      final screenSize = MediaQuery.sizeOf(context);
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: (screenSize.width * 0.92).clamp(0, 1200).toDouble(),
          height: (screenSize.height * 0.86).clamp(0, 900).toDouble(),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title != null && title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFFE5E2E1),
                            fontFamily: 'Cormorant',
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: SizedBox.expand(
                            child: _buildAdaptiveImage(
                              imageUrl,
                              fit: BoxFit.contain,
                              fallbackColor: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFFE5E2E1),
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

const String _heroImage =
    'assets/images/soul_of_the_renaissance_bg.png';

const String _artMainOne =
    'assets/images/madonna_of_the_goldfinch.png';
const String _artSideOne =
    'assets/images/the_creation_of_adam.png';
const String _artSideTwo =
    'assets/images/lady_with_an_ermine.png';
const String _artMainTwo =
    'assets/images/the_school_of_athens.png';

const String _mobileUiImage =
    'assets/images/landing_mobile_ui.png';

const String _featureMockupSearch =
    'assets/images/landing_feature_search.png';
const String _featureMockupDetail =
    'assets/images/landing_feature_detail.png';
const String _featureMockupCollection =
    'assets/images/landing_feature_collection.png';
const String _featureMockupMasterpieces =
    'assets/images/landing_feature_masterpieces.png';
