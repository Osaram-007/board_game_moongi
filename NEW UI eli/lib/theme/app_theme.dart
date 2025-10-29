import 'package:flutter/material.dart';

class AppTheme {
  // Dark Mode Colors
  static const Color darkBg = Color(0xFF0A0E27);
  static const Color darkBgSecondary = Color(0xFF1A1F3A);
  static const Color darkGlass = Color(0x1AFFFFFF);
  static const Color neonCyan = Color(0xFF00D9FF);
  static const Color neonMagenta = Color(0xFFFF006E);
  static const Color neonPurple = Color(0xFFB537F2);
  static const Color neonBlue = Color(0xFF0080FF);
  static const Color darkText = Color(0xFFFFFFFF);

  // Light Mode Colors
  static const Color lightBg = Color(0xFFF8F9FF);
  static const Color lightBgSecondary = Color(0xFFEEF2FF);
  static const Color lightGlass = Color(0x0D000000);
  static const Color accentBlue = Color(0xFF5B5FFF);
  static const Color accentPurple = Color(0xFF9D4EDD);
  static const Color accentTeal = Color(0xFF00B4D8);
  static const Color lightText = Color(0xFF1A1A2E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonCyan,
      colorScheme: ColorScheme.dark(
        primary: neonCyan,
        secondary: neonMagenta,
        tertiary: neonPurple,
        surface: darkBgSecondary,
        background: darkBg,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkText,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        displayMedium: TextStyle(
          color: darkText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        bodyLarge: TextStyle(
          color: darkText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFB0B0B0),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: accentBlue,
      colorScheme: ColorScheme.light(
        primary: accentBlue,
        secondary: accentPurple,
        tertiary: accentTeal,
        surface: lightBgSecondary,
        background: lightBg,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: lightText,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        displayMedium: TextStyle(
          color: lightText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        bodyLarge: TextStyle(
          color: lightText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF666666),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
