import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlacierColors {
  // Light Mode Colors
  static const Color lightBg = Color(0xFFEAF0F6);
  static const Color lightPrimary = Color(0xFF0A2342);
  static const Color lightAccent = Color(0xFF1D9E75);
  static final Color lightSurface = Colors.white.withOpacity(0.72);
  static final Color lightBorder = Colors.white.withOpacity(0.25);

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF0A1628);
  static const Color darkPrimary = Color(0xFF1D9E75);
  static const Color darkAccent = Color(0xFF4FC3F7);
  static final Color darkSurface = const Color(0xFF162235).withOpacity(0.5);
  static final Color darkBorder = Colors.white.withOpacity(0.12);

  // Semantic Colors (frosted badges)
  static final Color badgePendingBg = const Color(0xFFFFA500).withOpacity(0.15);
  static const Color badgePendingText = Color(0xFFD48200);

  static final Color badgeInProgressBg = const Color(0xFF673AB7).withOpacity(0.12);
  static const Color badgeInProgressText = Color(0xFF5E35B1);

  static final Color badgeQualityCheckBg = const Color(0xFF1565C0).withOpacity(0.12);
  static const Color badgeQualityCheckText = Color(0xFF0D47A1);

  static final Color badgeDeliveredBg = const Color(0xFF2E7D32).withOpacity(0.12);
  static const Color badgeDeliveredText = Color(0xFF1B5E20);
}

class GlacierTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: GlacierColors.lightPrimary,
      scaffoldBackgroundColor: GlacierColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: GlacierColors.lightPrimary,
        secondary: GlacierColors.lightAccent,
        background: GlacierColors.lightBg,
        surface: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: GlacierColors.lightPrimary,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: GlacierColors.lightPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: GlacierColors.lightPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF44474E),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: GlacierColors.darkPrimary,
      scaffoldBackgroundColor: GlacierColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: GlacierColors.darkPrimary,
        secondary: GlacierColors.darkAccent,
        background: GlacierColors.darkBg,
        surface: Color(0xFF0A1628),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }
}
