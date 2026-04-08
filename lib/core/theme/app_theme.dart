import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const base = Color(0xFF0D1117);
    const panel = Color(0xFF161B22);
    const accent = Color(0xFF58A6FF);
    const accent2 = Color(0xFF8B5CF6);

    final pixelifyFamily = GoogleFonts.pixelifySans().fontFamily;

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: pixelifyFamily,
      scaffoldBackgroundColor: base,
      primaryColor: accent,
      cardColor: panel,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF3FB950),
        surface: panel,
        error: Color(0xFFF85149),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: panel,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 15),
        bodyLarge: TextStyle(fontSize: 16),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: panel,
        contentTextStyle: const TextStyle(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: accent)),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF30363D)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: const Color(0xFF1F2937),
          foregroundColor: Colors.white,
          side: const BorderSide(color: accent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent2,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
      ),
    );
  }
}
