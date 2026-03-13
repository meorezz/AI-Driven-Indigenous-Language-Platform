import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary gradient (terracotta)
  static const gradientStart = Color(0xFFD98E73);
  static const gradientEnd = Color(0xFFB36A5B);

  // Lighter gradient variant
  static const gradientLightStart = Color(0xFFCAA398);
  static const gradientLightEnd = Color(0xFFB07266);

  // Text colors
  static const textLight = Color(0xFFFDF6F0);
  static const textCream = Color(0xFFFFF9F5);
  static const textDark = Color(0xFF2D1B17);
  static const textDarkMuted = Color(0x992D1B17); // 60% opacity

  // Surface
  static const surface = Color(0xFFF8F7F6);
  static const divider = Color(0x1A2D1B17); // 10% of dark

  // Status colors
  static const error = Color(0xFFBC4749);
  static const success = Color(0xFF2D6A4F);
  static const warning = Color(0xFFE9C46A);

  // Language status
  static const endangered = Color(0xFFBC4749);
  static const vulnerable = Color(0xFFE76F51);
  static const active = Color(0xFF2D6A4F);

  // Backward-compatible aliases (old names → new values)
  static const primary = gradientEnd;
  static const secondary = gradientLightStart;
  static const accent = Color(0xFFD4A373);
  static const background = surface;
  static const textPrimary = textDark;
  static const textSecondary = Color(0xFF52796F);

  // Gradient decoration
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientLightStart, gradientLightEnd],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gradientStart,
        primary: AppColors.gradientEnd,
        secondary: AppColors.gradientLightStart,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.notoSerifTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerif(
          fontSize: 24,
          fontStyle: FontStyle.italic,
          color: AppColors.textLight,
          letterSpacing: 4.8,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gradientEnd,
          foregroundColor: AppColors.textLight,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.notoSerif(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.textDark.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gradientEnd, width: 1.5),
        ),
      ),
    );
  }
}
