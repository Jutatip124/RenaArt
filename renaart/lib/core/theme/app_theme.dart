import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
//  RenaArt Design System v3
//  LIGHT  → Arts Gallery aesthetic (warm canvas, editorial serif, black badge)
//  DARK   → Museum Cinematic (deep charcoal, full-bleed, gold accent)
// ═══════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // LIGHT
  static const Color canvas      = Color(0xFFF7F4EF);
  static const Color canvasCard  = Color(0xFFFFFFFF);
  static const Color canvasTone  = Color(0xFFEEE8DF);
  static const Color ink         = Color(0xFF111111);
  static const Color inkBody     = Color(0xFF2C2C2C);
  static const Color inkMid      = Color(0xFF7A7069);
  static const Color inkLight    = Color(0xFFABA49B);
  static const Color inkHair     = Color(0xFFE4DDD4);
  static const Color badge       = Color(0xFF111111);
  static const Color accentWarm  = Color(0xFF8A5C3E);

  // DARK
  static const Color darkCanvas  = Color(0xFF141414);
  static const Color darkSurface = Color(0xFF1C1C1C);
  static const Color darkCard    = Color(0xFF242424);
  static const Color darkRaised  = Color(0xFF2C2C2C);
  static const Color darkBorder  = Color(0xFF313131);
  static const Color darkText    = Color(0xFFF2F2F2);
  static const Color darkSub     = Color(0xFFB0A89E);
  static const Color darkFaint   = Color(0xFF6A625A);
  static const Color gold        = Color(0xFFC8A84B);
  static const Color goldDim     = Color(0xFF8A7230);

  // Semantic
  static const Color heartRed    = Color(0xFFB03020);
  static const Color saveBlue    = Color(0xFF2C5F9E);
  static const Color errorRed    = Color(0xFFC0392B);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _light();
  static ThemeData get dark  => _dark();

  static ThemeData _light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: const ColorScheme.light(
      primary: AppColors.ink, secondary: AppColors.accentWarm,
      surface: AppColors.canvasCard, onSurface: AppColors.ink,
      outline: AppColors.inkHair,
    ),
    fontFamily: 'Jost',
    textTheme: const TextTheme(
      displayLarge:   TextStyle(fontFamily: 'Cormorant', fontSize: 48,
          fontWeight: FontWeight.w700, color: AppColors.ink,
          letterSpacing: -1.2, height: 1.02),
      headlineLarge:  TextStyle(fontFamily: 'Cormorant', fontSize: 28,
          fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.4),
      headlineMedium: TextStyle(fontFamily: 'Cormorant', fontSize: 22,
          fontWeight: FontWeight.w600, color: AppColors.ink),
      titleLarge:     TextStyle(fontFamily: 'Jost', fontSize: 16,
          fontWeight: FontWeight.w500, color: AppColors.inkBody),
      titleMedium:    TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w500, color: AppColors.inkBody),
      bodyLarge:      TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w300, height: 1.65, color: AppColors.inkMid),
      bodyMedium:     TextStyle(fontFamily: 'Jost', fontSize: 12,
          height: 1.5, color: AppColors.inkLight),
      labelLarge:     TextStyle(fontFamily: 'Jost', fontSize: 11,
          fontWeight: FontWeight.w600, letterSpacing: 1.2, color: AppColors.ink),
      labelMedium:    TextStyle(fontFamily: 'Jost', fontSize: 10,
          fontWeight: FontWeight.w500, letterSpacing: 1.0, color: AppColors.inkMid),
      labelSmall:     TextStyle(fontFamily: 'Jost', fontSize: 9,
          fontWeight: FontWeight.w500, letterSpacing: 1.4, color: AppColors.inkLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas, elevation: 0,
      scrolledUnderElevation: 0, foregroundColor: AppColors.ink,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: 'Cormorant', fontSize: 24,
          fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,
          color: AppColors.ink, letterSpacing: -0.3),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.canvasCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inkHair, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.inkHair, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5)),
      hintStyle: const TextStyle(fontFamily: 'Jost', fontSize: 13,
          color: AppColors.inkLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.ink, foregroundColor: Colors.white,
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(fontFamily: 'Jost', fontSize: 13,
          fontWeight: FontWeight.w500, letterSpacing: 0.6),
    )),
    cardTheme: CardThemeData(color: AppColors.canvasCard, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.inkHair, width: 0.8))),
    dividerTheme: const DividerThemeData(color: AppColors.inkHair, thickness: 0.8, space: 0),
  );

  static ThemeData _dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkCanvas,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold, secondary: AppColors.gold,
      surface: AppColors.darkSurface, onSurface: AppColors.darkText,
      outline: AppColors.darkBorder,
    ),
    fontFamily: 'Jost',
    textTheme: const TextTheme(
      displayLarge:   TextStyle(fontFamily: 'Cormorant', fontSize: 48,
          fontWeight: FontWeight.w700, color: AppColors.darkText,
          letterSpacing: -1.2, height: 1.02),
      headlineLarge:  TextStyle(fontFamily: 'Cormorant', fontSize: 28,
          fontWeight: FontWeight.w600, color: AppColors.darkText, letterSpacing: -0.4),
      headlineMedium: TextStyle(fontFamily: 'Cormorant', fontSize: 22,
          fontWeight: FontWeight.w600, color: AppColors.darkText),
      titleLarge:     TextStyle(fontFamily: 'Jost', fontSize: 16,
          fontWeight: FontWeight.w500, color: AppColors.darkText),
      titleMedium:    TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w400, color: AppColors.darkSub),
      bodyLarge:      TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w300, height: 1.65, color: AppColors.darkSub),
      bodyMedium:     TextStyle(fontFamily: 'Jost', fontSize: 12,
          height: 1.5, color: AppColors.darkFaint),
      labelLarge:     TextStyle(fontFamily: 'Jost', fontSize: 11,
          fontWeight: FontWeight.w600, letterSpacing: 1.2, color: AppColors.darkText),
      labelMedium:    TextStyle(fontFamily: 'Jost', fontSize: 10,
          fontWeight: FontWeight.w500, letterSpacing: 1.0, color: AppColors.darkFaint),
      labelSmall:     TextStyle(fontFamily: 'Jost', fontSize: 9,
          fontWeight: FontWeight.w500, letterSpacing: 1.4, color: AppColors.darkFaint),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkCanvas, elevation: 0,
      scrolledUnderElevation: 0, foregroundColor: AppColors.darkText,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: 'Cormorant', fontSize: 24,
          fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,
          color: AppColors.darkText, letterSpacing: -0.3),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
      hintStyle: const TextStyle(fontFamily: 'Jost', fontSize: 13,
          color: AppColors.darkFaint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkText, foregroundColor: AppColors.darkCanvas,
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(fontFamily: 'Jost', fontSize: 13,
          fontWeight: FontWeight.w600, letterSpacing: 0.6),
    )),
    cardTheme: CardThemeData(color: AppColors.darkCard, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5))),
    dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 0.8, space: 0),
  );
}
