import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../home/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();

    // Navigate after preload delay
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final auth = ref.read(authProvider);
      context.go(auth != null ? AppRoutes.home : AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo mark
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.sienna,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      'RA',
                      style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'RenaArt',
                  style: TextStyle(
                    fontFamily: 'Cormorant',
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkText : AppColors.inkDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The Digital Museum of the Renaissance',
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.8,
                    color: isDark
                        ? AppColors.darkTextFaint
                        : AppColors.inkFaint,
                  ),
                ),
                const SizedBox(height: 52),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.sienna.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading artworks...',
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextFaint
                        : AppColors.inkFaint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
