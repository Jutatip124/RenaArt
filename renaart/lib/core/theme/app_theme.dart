import 'package:flutter/material.dart';

/// Week 5 Spec: Color palette = Parchment, Sienna, Gold
/// "creating a cohesive and authentic museum aesthetic"
class AppColors {
  AppColors._();

  // ─── Light (Museum Parchment) ──────────────────────────────────────────────
  static const Color parchment = Color(0xFFF5F0E8);
  static const Color parchmentDark = Color(0xFFEDE5D0);
  static const Color sienna = Color(0xFF8B3A2A);
  static const Color siennaLight = Color(0xFFA84E3A);
  static const Color gold = Color(0xFFC49A3C);
  static const Color goldLight = Color(0xFFD4AF5A);
  static const Color inkDark = Color(0xFF1A1208);
  static const Color inkMedium = Color(0xFF3D2E1A);
  static const Color inkLight = Color(0xFF6B5744);
  static const Color inkFaint = Color(0xFF9B8A78);
  static const Color surfaceWhite = Color(0xFFFAF7F2);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8DFC8);
  static const Color tagBg = Color(0xFFEDE5D0);

  // ─── Dark (Dark Museum) ───────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0F0B07);
  static const Color darkSurface = Color(0xFF1A140C);
  static const Color darkCard = Color(0xFF221A10);
  static const Color darkBorder = Color(0xFF2E2318);
  static const Color darkText = Color(0xFFF0E8D8);
  static const Color darkTextSecondary = Color(0xFFB8A898);
  static const Color darkTextFaint = Color(0xFF7A6A58);
  static const Color tagBgDark = Color(0xFF2E2318);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color heartRed = Color(0xFFB03A2A);
  static const Color offlineBlue = Color(0xFF2A5FAA);
  static const Color errorRed = Color(0xFFCC3333);
  static const Color successGreen = Color(0xFF2D6A4F);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: isDark ? AppColors.siennaLight : AppColors.sienna,
        onPrimary: Colors.white,
        secondary: isDark ? AppColors.goldLight : AppColors.gold,
        onSecondary: AppColors.inkDark,
        error: AppColors.errorRed,
        onError: Colors.white,
        surface: isDark ? AppColors.darkSurface : AppColors.surfaceWhite,
        onSurface: isDark ? AppColors.darkText : AppColors.inkDark,
        outline: isDark ? AppColors.darkBorder : AppColors.divider,
      ),
      fontFamily: 'Jost',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.inkDark,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.inkDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.inkDark,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Jost',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkText : AppColors.inkDark,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Jost',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
          letterSpacing: 0.15,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Jost',
          fontSize: 15,
          height: 1.65,
          color: isDark ? AppColors.darkTextSecondary : AppColors.inkMedium,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Jost',
          fontSize: 13,
          height: 1.5,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkLight,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Jost',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: isDark ? AppColors.darkText : AppColors.inkDark,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Jost',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.0,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: isDark ? AppColors.darkText : AppColors.inkDark,
        titleTextStyle: TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: isDark ? AppColors.darkText : AppColors.inkDark,
          letterSpacing: 0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.divider,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.divider,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.siennaLight : AppColors.sienna,
            width: 1.5,
          ),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Jost',
          fontSize: 14,
          color: isDark ? AppColors.darkTextFaint : AppColors.inkFaint,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkCard : AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.siennaLight : AppColors.sienna,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Jost',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkBorder : AppColors.divider,
        thickness: 0.5,
        space: 0,
      ),
    );
  }
}
