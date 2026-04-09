import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const base = Color(0xFF050807);
    const panel = Color(0xFF0A0F0D);
    const glassPanel = Color(0xE60A0F0D);
    const glassBorder = Color(0xFF1F5A41);
    const accent = Color(0xFF2CFF8F);
    const textPrimary = Color(0xFFB7FFD8);
    final pixelTextTheme = ThemeData.dark().textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
      fontFamily: 'PixelifySans',
    );

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'PixelifySans',
      scaffoldBackgroundColor: base,
      primaryColor: accent,
      cardColor: panel,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF73FFD9),
        surface: panel,
        error: Color(0xFFFF6464),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xEE070C0A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontFamily: 'PixelifySans',
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: pixelTextTheme.copyWith(
        bodyMedium: pixelTextTheme.bodyMedium?.copyWith(fontSize: 15),
        bodyLarge: pixelTextTheme.bodyLarge?.copyWith(fontSize: 16),
        titleLarge: pixelTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: pixelTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: pixelTextTheme.labelLarge,
      ),
      primaryTextTheme: pixelTextTheme,
      iconTheme: const IconThemeData(color: textPrimary),
      dividerColor: const Color(0xFF333333),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xE6070C0A),
        contentTextStyle: const TextStyle(color: textPrimary, fontFamily: 'PixelifySans'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: glassBorder),
        ),
      ),
      cardTheme: CardThemeData(
        color: glassPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: glassBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: const Color(0xEE07110C),
          foregroundColor: textPrimary,
          side: const BorderSide(color: glassBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'PixelifySans'),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: glassBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontFamily: 'PixelifySans', fontWeight: FontWeight.w600),
          backgroundColor: const Color(0xAA07110C),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          textStyle: const TextStyle(fontFamily: 'PixelifySans', fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: textPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: glassPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: glassBorder),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'PixelifySans',
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'PixelifySans',
          color: textPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: glassPanel,
        modalBackgroundColor: glassPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          side: BorderSide(color: glassBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xCC07110C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: accent),
        ),
        hintStyle: const TextStyle(fontFamily: 'PixelifySans'),
        labelStyle: const TextStyle(fontFamily: 'PixelifySans'),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeSlidePageTransitionsBuilder(),
          TargetPlatform.iOS: _FadeSlidePageTransitionsBuilder(),
          TargetPlatform.macOS: _FadeSlidePageTransitionsBuilder(),
          TargetPlatform.windows: _FadeSlidePageTransitionsBuilder(),
          TargetPlatform.linux: _FadeSlidePageTransitionsBuilder(),
        },
      ),
    );
  }
}

class _FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final offset = Tween<Offset>(
      begin: const Offset(0.04, 0.02),
      end: Offset.zero,
    ).animate(curved);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: offset, child: child),
    );
  }
}
