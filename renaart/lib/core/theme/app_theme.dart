import 'package:flutter/material.dart';

class AppColors {
  // Light Mode - Parchment Museum Palette
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
  static const Color surfaceLight = Color(0xFFFAF7F2);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE8DFC8);

  // Dark Mode - Dark Museum Palette
  static const Color darkBg = Color(0xFF0F0B07);
  static const Color darkSurface = Color(0xFF1A140C);
  static const Color darkCard = Color(0xFF221A10);
  static const Color darkBorder = Color(0xFF2E2318);
  static const Color darkText = Color(0xFFF0E8D8);
  static const Color darkTextSecondary = Color(0xFFB8A898);
  static const Color darkTextFaint = Color(0xFF7A6A58);

  // Accent - same in both modes
  static const Color heartRed = Color(0xFFB03A2A);
  static const Color offlineBlue = Color(0xFF2A5FAA);
  static const Color tagBg = Color(0xFFEDE5D0);
  static const Color tagBgDark = Color(0xFF2E2318);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.parchment,
    colorScheme: const ColorScheme.light(
      primary: AppColors.sienna,
      secondary: AppColors.gold,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.inkDark,
      outline: AppColors.dividerLight,
    ),
    fontFamily: 'Jost',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 48,
        fontWeight: FontWeight.w600,
        color: AppColors.inkDark,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: AppColors.inkDark,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.inkDark,
        letterSpacing: 0.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.inkDark,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Jost',
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.inkDark,
        letterSpacing: 0.1,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Jost',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.inkMedium,
        letterSpacing: 0.15,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Jost',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.inkMedium,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Jost',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.inkLight,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Jost',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.inkDark,
        letterSpacing: 0.8,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Jost',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.inkFaint,
        letterSpacing: 1.0,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.parchment,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.inkDark,
      titleTextStyle: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.inkDark,
        letterSpacing: 0.3,
        fontStyle: FontStyle.italic,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.sienna,
      unselectedItemColor: AppColors.inkFaint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Jost',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Jost',
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.sienna, width: 1.5),
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Jost',
        color: AppColors.inkFaint,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerLight, width: 0.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.tagBg,
      selectedColor: AppColors.sienna,
      labelStyle: const TextStyle(
        fontFamily: 'Jost',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.inkMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.dividerLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sienna,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Jost',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        elevation: 0,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 0.5,
      space: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.siennaLight,
      secondary: AppColors.goldLight,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      outline: AppColors.darkBorder,
    ),
    fontFamily: 'Jost',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 48,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Jost',
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Jost',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextSecondary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Jost',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Jost',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextFaint,
        height: 1.5,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Jost',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextFaint,
        letterSpacing: 1.0,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.darkText,
      titleTextStyle: TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        letterSpacing: 0.3,
        fontStyle: FontStyle.italic,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.goldLight,
      unselectedItemColor: AppColors.darkTextFaint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.siennaLight, width: 1.5),
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Jost',
        color: AppColors.darkTextFaint,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.tagBgDark,
      selectedColor: AppColors.siennaLight,
      labelStyle: const TextStyle(
        fontFamily: 'Jost',
        fontSize: 12,
        color: AppColors.darkTextSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.siennaLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Jost',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        elevation: 0,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 0.5,
      space: 0,
    ),
  );
}
