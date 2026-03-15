import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
//  RenaArt Design System v4 — Modern Minimalist × Art Gallery
//  Inspired by Character.ai / clean SaaS aesthetic
//  Light: near-white bg, pure-white cards, near-black text
//  Dark:  matte black, deep grey surface, white text
//  Buttons: Stadium (capsule) shape — pill at every size
//  Cards:   BorderRadius.circular(20)
//  Inputs:  BorderRadius.circular(16)
// ═══════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ─── Light Palette ────────────────────────────────────────────────
  static const Color lightBg      = Color(0xFFF6F6F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText    = Color(0xFF111111);
  static const Color lightSub     = Color(0xFF666666);
  static const Color lightBorder  = Color(0xFFE5E5E5);

  // ─── Dark Palette ─────────────────────────────────────────────────
  static const Color darkBg       = Color(0xFF0E0E0E);
  static const Color darkSurface  = Color(0xFF1A1A1A);
  static const Color darkText     = Color(0xFFFFFFFF);
  static const Color darkSub      = Color(0xFFB3B3B3);
  static const Color darkBorder   = Color(0xFF2C2C2C);

  // ─── Accent ───────────────────────────────────────────────────────
  static const Color accentBlueLight = Color(0xFF1E88E5); // light accent
  static const Color accentBlueDark  = Color(0xFF64B5F6); // dark accent
  static const Color accent          = Color(0xFFC8A84B); // gold (legacy)
  static const Color error           = Color(0xFFE53935);

  // ─── Backward-compat aliases ──────────────────────────────────────
  static const Color canvas        = lightBg;
  static const Color canvasCard    = lightSurface;
  static const Color canvasTone    = Color(0xFFEEEEEE);
  static const Color ink           = lightText;
  static const Color inkBody       = Color(0xFF333333);
  static const Color inkMid        = lightSub;
  static const Color inkLight      = Color(0xFF999999);
  static const Color inkHair       = lightBorder;
  static const Color badge         = lightText;
  static const Color accentWarm    = Color(0xFF8A5C3E);
  static const Color darkCanvas    = darkBg;
  static const Color darkCard      = Color(0xFF1A1A1A); // = darkSurface
  static const Color darkRaised    = darkBorder;
  static const Color darkFaint     = Color(0xFF5A5A5A);
  static const Color gold          = accent;
  static const Color goldDim       = Color(0xFF8A7230);
  static const Color heartRed      = error;
  static const Color saveBlue      = accent; // gold — matches dark mode accent
  static const Color errorRed      = error;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _light();
  static ThemeData get dark  => _dark();

  /// Themed success SnackBar — floating at top, rounded, green check icon.
  static SnackBar successSnackBar(BuildContext context, String message, {Duration? duration}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(message,
            style: TextStyle(fontFamily: 'Jost', fontSize: 14,
                color: isDark ? Colors.white : AppColors.ink))),
      ]),
      backgroundColor: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
      dismissDirection: DismissDirection.up,
      elevation: 4,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  // ─── LIGHT ────────────────────────────────────────────────────────
  static ThemeData _light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary:   AppColors.lightText,
      secondary: AppColors.accent,
      surface:   AppColors.lightSurface,
      onSurface: AppColors.lightText,
      outline:   AppColors.lightBorder,
      error:     AppColors.error,
    ),
    fontFamily: 'Jost',
    textTheme: const TextTheme(
      // H1 — 28 / 700
      displayLarge:   TextStyle(fontFamily: 'Jost', fontSize: 28,
          fontWeight: FontWeight.w700, color: AppColors.lightText, letterSpacing: -0.5),
      // H2 — 20 / 600
      headlineLarge:  TextStyle(fontFamily: 'Jost', fontSize: 20,
          fontWeight: FontWeight.w600, color: AppColors.lightText),
      headlineMedium: TextStyle(fontFamily: 'Jost', fontSize: 20,
          fontWeight: FontWeight.w600, color: AppColors.lightText),
      // Card Title — 18 / 600
      titleLarge:     TextStyle(fontFamily: 'Jost', fontSize: 18,
          fontWeight: FontWeight.w600, color: AppColors.lightText),
      // Body — 14 / 400
      titleMedium:    TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w400, color: AppColors.lightSub),
      bodyLarge:      TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w400, color: AppColors.lightText),
      bodyMedium:     TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w400, color: AppColors.lightSub),
      // Chip — 13 / 500
      labelLarge:     TextStyle(fontFamily: 'Jost', fontSize: 13,
          fontWeight: FontWeight.w500, letterSpacing: 0.2),
      // Caption — 12 / 400
      labelMedium:    TextStyle(fontFamily: 'Jost', fontSize: 12,
          fontWeight: FontWeight.w400, color: AppColors.lightSub),
      labelSmall:     TextStyle(fontFamily: 'Jost', fontSize: 12,
          fontWeight: FontWeight.w400, color: AppColors.inkLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg, elevation: 0,
      scrolledUnderElevation: 0, foregroundColor: AppColors.lightText,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: 'Cormorant', fontSize: 24,
          fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,
          color: AppColors.lightText, letterSpacing: -0.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightText,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600,
            fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightText,
        side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600,
            fontSize: 14),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.lightBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.lightText, width: 1.5)),
      hintStyle: const TextStyle(fontFamily: 'Jost', fontSize: 13,
          color: AppColors.inkLight),
    ),
    dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder, thickness: 0.8, space: 0),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFFF0F0F0),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      contentTextStyle: TextStyle(fontFamily: 'Jost', fontSize: 14, color: AppColors.ink),
    ),
  );

  // ─── DARK ─────────────────────────────────────────────────────────
  static ThemeData _dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.darkText,
      secondary: AppColors.accent,
      surface:   AppColors.darkSurface,
      onSurface: AppColors.darkText,
      outline:   AppColors.darkBorder,
      error:     AppColors.error,
    ),
    fontFamily: 'Jost',
    textTheme: const TextTheme(
      displayLarge:   TextStyle(fontFamily: 'Jost', fontSize: 28,
          fontWeight: FontWeight.w700, color: AppColors.darkText, letterSpacing: -0.5),
      headlineLarge:  TextStyle(fontFamily: 'Jost', fontSize: 20,
          fontWeight: FontWeight.w600, color: AppColors.darkText),
      headlineMedium: TextStyle(fontFamily: 'Jost', fontSize: 20,
          fontWeight: FontWeight.w600, color: AppColors.darkText),
      titleLarge:     TextStyle(fontFamily: 'Jost', fontSize: 18,
          fontWeight: FontWeight.w600, color: AppColors.darkText),
      titleMedium:    TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w400, color: AppColors.darkSub),
      bodyLarge:      TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w400, color: AppColors.darkText),
      bodyMedium:     TextStyle(fontFamily: 'Jost', fontSize: 14,
          fontWeight: FontWeight.w400, color: AppColors.darkSub),
      labelLarge:     TextStyle(fontFamily: 'Jost', fontSize: 13,
          fontWeight: FontWeight.w500, letterSpacing: 0.2),
      labelMedium:    TextStyle(fontFamily: 'Jost', fontSize: 12,
          fontWeight: FontWeight.w400, color: AppColors.darkSub),
      labelSmall:     TextStyle(fontFamily: 'Jost', fontSize: 12,
          fontWeight: FontWeight.w400, color: AppColors.darkFaint),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg, elevation: 0,
      scrolledUnderElevation: 0, foregroundColor: AppColors.darkText,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: 'Cormorant', fontSize: 24,
          fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,
          color: AppColors.darkText, letterSpacing: -0.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkText,
        foregroundColor: AppColors.darkBg,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600,
            fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600,
            fontSize: 14),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0, // no shadow in dark
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.darkBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.darkText, width: 1.5)),
      hintStyle: const TextStyle(fontFamily: 'Jost', fontSize: 13,
          color: AppColors.darkFaint),
    ),
    dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder, thickness: 0.8, space: 0),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF3A3A3A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      contentTextStyle: TextStyle(fontFamily: 'Jost', fontSize: 14, color: Colors.white),
    ),
  );
}
