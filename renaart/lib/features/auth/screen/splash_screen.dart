import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/app_providers.dart';

// Splash — Museum cinematic: full-dark, large serif, subtle gold rule
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashState();
}

class _SplashState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.7, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      context.go(ref.read(authProvider) != null ? AppRoutes.home : AppRoutes.login);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg   = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final sub  = isDark ? AppColors.darkFaint  : AppColors.inkLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Logo — white in dark, black in light
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : AppColors.ink,
                  BlendMode.srcIn,
                ),
                child: Image.asset('assets/images/logo_dark.png',
                    width: 240, height: 240),
              ),
              const SizedBox(height: 6),
              // Gold rule
              Container(width: 40, height: 1,
                  color: isDark ? AppColors.gold : AppColors.inkLight),
              const SizedBox(height: 10),
              Text(AppConstants.appTagline.toUpperCase(),
                style: TextStyle(fontFamily: 'Jost', fontSize: 9,
                    fontWeight: FontWeight.w500, letterSpacing: 2.8, color: sub)),
              const SizedBox(height: 4),
              Text('v${AppConstants.appVersion}',
                style: TextStyle(fontFamily: 'Jost', fontSize: 9,
                    fontWeight: FontWeight.w300, letterSpacing: 1.2, color: sub.withValues(alpha: 0.5))),
              const SizedBox(height: 56),
              SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 1.2,
                  color: isDark ? AppColors.gold.withValues(alpha: 0.5)
                      : AppColors.inkLight,
                ),
              ),
            ]),
          ),
        ),
      ),
      ),
    );
  }
}
