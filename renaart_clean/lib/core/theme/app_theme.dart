import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core palette — Renaissance parchment & sienna
  static const cream = Color(0xFFF7F3ED);
  static const parchment = Color(0xFFEDE5D8);
  static const ink = Color(0xFF1A1208);
  static const sienna = Color(0xFF8B3A1D);
  static const gold = Color(0xFFC9973B);
  static const goldLight = Color(0xFFE8C77A);
  static const stone = Color(0xFF8C8070);
  static const darkBrown = Color(0xFF2A1508);

  // Semantic
  static const error = Color(0xFFC0392B);
  static const success = Color(0xFF27AE60);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.light(
        primary: AppColors.sienna,
        secondary: AppColors.gold,
        surface: AppColors.cream,
        onPrimary: Colors.white,
        onSecondary: AppColors.ink,
        onSurface: AppColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 22,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
          color: AppColors.sienna,
          letterSpacing: 1,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cream,
        selectedItemColor: AppColors.sienna,
        unselectedItemColor: AppColors.stone,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 32, fontWeight: FontWeight.w300, color: AppColors.ink,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.ink,
        ),
        titleLarge: GoogleFonts.cormorantGaramond(
          fontSize: 22, fontWeight: FontWeight.w400, color: AppColors.ink,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.ink,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14, color: const Color(0xFF4A3E2E),
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12, color: AppColors.stone,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w600,
          letterSpacing: 1.2, color: AppColors.stone,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.parchment,
        selectedColor: AppColors.ink,
        labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.parchment),
        ),
      ),
    );
  }
}
