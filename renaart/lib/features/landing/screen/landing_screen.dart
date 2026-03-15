// Public landing page at /landing — app intro, feature highlights, and Get Started CTA.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;

    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final text = isDark ? AppColors.darkText : AppColors.ink;
    final sub = isDark ? AppColors.darkSub : AppColors.inkMid;
    final card = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    const gold = AppColors.gold;

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(children: [
          // ─── Hero Section ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? w * 0.15 : 24,
              vertical: isWide ? 80 : 56,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF1A1A1A), AppColors.darkBg]
                    : [Colors.white, AppColors.lightBg],
              ),
            ),
            child: Column(children: [
              // Logo
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : AppColors.ink,
                  BlendMode.srcIn,
                ),
                child: Image.asset('assets/images/logo_dark.png',
                    height: isWide ? 100 : 72),
              ),
              const SizedBox(height: 20),
              // Tagline
              Text(
                'The Digital Museum\nof the Renaissance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cormorant',
                  fontSize: isWide ? 40 : 28,
                  fontWeight: FontWeight.w600,
                  color: text,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Container(width: 40, height: 2, color: gold),
              const SizedBox(height: 14),
              Text(
                'Explore 300 masterpieces from the Renaissance era (1300-1600)\nwith rich historical context, meaning & symbolism.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: isWide ? 16 : 14,
                  color: sub,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // CTA Button
              SizedBox(
                width: isWide ? 220 : double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.splash),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Get Started',
                      style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.2)),
                ),
              ),
            ]),
          ),

          // ─── Features Section ──────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? w * 0.12 : 20,
              vertical: 40,
            ),
            child: Column(children: [
              Text('Features',
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: isWide ? 30 : 24,
                    fontWeight: FontWeight.w600,
                    color: text,
                  )),
              const SizedBox(height: 6),
              Container(width: 30, height: 2, color: gold),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _FeatureCard(
                    icon: Icons.museum_outlined,
                    title: '300 Artworks',
                    desc: 'Paintings, sculptures, frescoes, drawings & prints by 16 Renaissance masters.',
                    card: card, border: border, text: text, sub: sub, gold: gold,
                    isWide: isWide,
                  ),
                  _FeatureCard(
                    icon: Icons.search,
                    title: 'Smart Search',
                    desc: 'Filter by artist, title, art form, subject, period, and region with autocomplete.',
                    card: card, border: border, text: text, sub: sub, gold: gold,
                    isWide: isWide,
                  ),
                  _FeatureCard(
                    icon: Icons.info_outline,
                    title: 'Rich Details',
                    desc: 'Historical background, meaning & symbolism, key symbols for every artwork.',
                    card: card, border: border, text: text, sub: sub, gold: gold,
                    isWide: isWide,
                  ),
                  _FeatureCard(
                    icon: Icons.favorite_border,
                    title: 'Personal Collection',
                    desc: 'Save your favorite artworks. Per-user — your collection stays with you.',
                    card: card, border: border, text: text, sub: sub, gold: gold,
                    isWide: isWide,
                  ),
                  _FeatureCard(
                    icon: Icons.download_outlined,
                    title: 'Offline Access',
                    desc: 'Save up to 10 artworks locally for viewing without internet.',
                    card: card, border: border, text: text, sub: sub, gold: gold,
                    isWide: isWide,
                  ),
                  _FeatureCard(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark & Light Mode',
                    desc: 'Modern Art Gallery aesthetic in both themes for comfortable viewing.',
                    card: card, border: border, text: text, sub: sub, gold: gold,
                    isWide: isWide,
                  ),
                ],
              ),
            ]),
          ),

          // ─── Tech Section ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? w * 0.15 : 24,
              vertical: 36,
            ),
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: Column(children: [
              Text('Built With',
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: isWide ? 26 : 20,
                    fontWeight: FontWeight.w600,
                    color: text,
                  )),
              const SizedBox(height: 6),
              Container(width: 30, height: 2, color: gold),
              const SizedBox(height: 20),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _TechBadge('Flutter', sub),
                  _TechBadge('Firebase Auth', sub),
                  _TechBadge('Cloud Firestore', sub),
                  _TechBadge('Riverpod', sub),
                  _TechBadge('GoRouter', sub),
                  _TechBadge('Hive', sub),
                ],
              ),
            ]),
          ),

          // ─── Footer ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(children: [
              Container(width: 30, height: 2, color: gold),
              const SizedBox(height: 14),
              Text('RenaArt 2026',
                  style: TextStyle(
                      fontFamily: 'Jost', fontSize: 12, color: sub)),
              const SizedBox(height: 4),
              Text('Mobile Application Development - Mini Project',
                  style: TextStyle(
                      fontFamily: 'Jost', fontSize: 11, color: sub)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color card, border, text, sub, gold;
  final bool isWide;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.card,
    required this.border,
    required this.text,
    required this.sub,
    required this.gold,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? 200 : double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: gold),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                fontFamily: 'Cormorant',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: text,
              )),
          const SizedBox(height: 6),
          Text(desc,
              textAlign: isWide ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 12,
                color: sub,
                height: 1.4,
              )),
        ],
      ),
    );
  }
}

class _TechBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TechBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 0.5));
  }
}
