import 'package:flutter/material.dart';

class AppTheme {
  static const Color ink = Color(0xFF122033);
  static const Color slate = Color(0xFF5D6B82);
  static const Color sky = Color(0xFFEAF4FF);
  static const Color surface = Color(0xFFF7F5F0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color aqua = Color(0xFF3AAFA9);
  static const Color amber = Color(0xFFFFB86B);
  static const Color coral = Color(0xFFF06C5F);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: aqua,
      brightness: Brightness.light,
      primary: ink,
      secondary: aqua,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.15,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: slate,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: ink,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        backgroundColor: sky,
        labelStyle: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
