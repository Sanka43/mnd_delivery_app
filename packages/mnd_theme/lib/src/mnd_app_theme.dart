import 'package:flutter/material.dart';

import 'mnd_brand_palette.dart';

/// Semantic colors that stay distinct on the blue-teal brand system.
abstract final class MndPalette {
  static const positive = Color(0xFF059669);
  static const warning = Color(0xFFD97706);
}

/// Material 3 themes built from [MndBrandColors].
abstract final class MndAppTheme {
  static ThemeData get light {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: MndBrandColors.royal,
      onPrimary: Colors.white,
      primaryContainer: MndBrandColors.powder,
      onPrimaryContainer: MndBrandColors.navy,
      secondary: MndBrandColors.tealBlue,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD0EBF2),
      onSecondaryContainer: MndBrandColors.navy,
      tertiary: MndBrandColors.sky,
      onTertiary: MndBrandColors.navy,
      tertiaryContainer: const Color(0xFFE3F2FA),
      onTertiaryContainer: MndBrandColors.navy,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: MndBrandColors.powder,
      onSurface: MndBrandColors.navy,
      surfaceContainerHighest: const Color(0xFFC5DCEC),
      surfaceContainerHigh: const Color(0xFFD0E3F0),
      surfaceContainer: const Color(0xFFDDEAF4),
      surfaceContainerLow: const Color(0xFFE8F1F7),
      surfaceContainerLowest: Colors.white,
      onSurfaceVariant: MndBrandColors.blueMuted,
      outline: MndBrandColors.blueTeal,
      outlineVariant: const Color(0xFFD0E3ED),
      shadow: MndBrandColors.navy.withValues(alpha: 0.18),
      scrim: MndBrandColors.navy.withValues(alpha: 0.45),
      inverseSurface: MndBrandColors.navy,
      onInverseSurface: MndBrandColors.powder,
      inversePrimary: MndBrandColors.sky,
      surfaceTint: MndBrandColors.royal,
    );

    return _buildTheme(scheme);
  }

  static ThemeData get dark {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: MndBrandColors.sky,
      onPrimary: MndBrandColors.navy,
      primaryContainer: MndBrandColors.royal,
      onPrimaryContainer: MndBrandColors.powder,
      secondary: MndBrandColors.blueTeal,
      onSecondary: MndBrandColors.navy,
      secondaryContainer: const Color(0xFF2A5A6B),
      onSecondaryContainer: const Color(0xFFBDD8E9),
      tertiary: MndBrandColors.tealBlue,
      onTertiary: Colors.white,
      tertiaryContainer: MndBrandColors.blueMuted,
      onTertiaryContainer: MndBrandColors.powder,
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: MndBrandColors.navy,
      onSurface: MndBrandColors.powder,
      surfaceContainerHighest: const Color(0xFF2A4A62),
      surfaceContainerHigh: const Color(0xFF223D52),
      surfaceContainer: const Color(0xFF1A3347),
      surfaceContainerLow: const Color(0xFF152B3D),
      surfaceContainerLowest: const Color(0xFF00152A),
      onSurfaceVariant: MndBrandColors.sky,
      outline: MndBrandColors.blueTeal,
      outlineVariant: MndBrandColors.blueMuted,
      shadow: Colors.black.withValues(alpha: 0.35),
      scrim: Colors.black.withValues(alpha: 0.55),
      inverseSurface: MndBrandColors.powder,
      onInverseSurface: MndBrandColors.navy,
      inversePrimary: MndBrandColors.royal,
      surfaceTint: MndBrandColors.sky,
    );

    return _buildTheme(scheme);
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(16);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.65),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow.withValues(alpha: isDark ? 0.85 : 1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: scheme.outline.withValues(alpha: isDark ? 0.6 : 0.85),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer.withValues(alpha: isDark ? 0.35 : 0.55),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.35),
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
