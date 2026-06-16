import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFF0891B2);
  static const accent = Color(0xFFEA580C);
  static const danger = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const amber = Color(0xFFD97706);

  static const lightBg = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightMuted = Color(0xFFF1F5F9);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightText = Color(0xFF0F172A);
  static const lightSubtle = Color(0xFF64748B);

  static const darkBg = Color(0xFF0B1120);
  static const darkSurface = Color(0xFF131C2E);
  static const darkMuted = Color(0xFF1C2740);
  static const darkBorder = Color(0xFF273349);
  static const darkText = Color(0xFFE8EDF6);
  static const darkSubtle = Color(0xFF93A1B8);
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: dark ? AppColors.darkText : AppColors.lightText,
    displayColor: dark ? AppColors.darkText : AppColors.lightText,
  );

  final scheme = ColorScheme(
    brightness: brightness,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    tertiary: AppColors.accent,
    onTertiary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    surface: dark ? AppColors.darkSurface : AppColors.lightSurface,
    onSurface: dark ? AppColors.darkText : AppColors.lightText,
    surfaceContainerHighest: dark ? AppColors.darkMuted : AppColors.lightMuted,
    outline: dark ? AppColors.darkBorder : AppColors.lightBorder,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
      foregroundColor: dark ? AppColors.darkText : AppColors.lightText,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: dark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: dark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? AppColors.darkMuted : AppColors.lightMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      hintStyle: TextStyle(color: dark ? AppColors.darkSubtle : AppColors.lightSubtle),
    ),
    dividerTheme: DividerThemeData(
      color: dark ? AppColors.darkBorder : AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.14),
      elevation: 0,
      height: 66,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelMedium?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected
              ? AppColors.primary
              : (dark ? AppColors.darkSubtle : AppColors.lightSubtle),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected
              ? AppColors.primary
              : (dark ? AppColors.darkSubtle : AppColors.lightSubtle),
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class Insets {
  static const page = EdgeInsets.symmetric(horizontal: 16);
  static const double gap = 12;
  static const double section = 24;
}
