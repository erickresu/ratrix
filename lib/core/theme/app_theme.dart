import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Swap for your brand palette.
abstract class AppColors {
  static const primary = Color(0xFF5D3FD3);
  static const secondary = Color(0xFF64748B);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFDC2626);
  static const background = Color(0xFFEEF1F6);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const onSurfaceMuted = Color(0xFF64748B);
}

enum AppColorKey {
  primary,
  secondary,
  success,
  warning,
  error,
  onSurfaceMuted,
  text,
}

class TextStyleUtil {
  TextStyleUtil._();

  static Color _color(BuildContext context, AppColorKey key) {
    switch (key) {
      case AppColorKey.primary:
        return AppColors.primary;
      case AppColorKey.secondary:
        return AppColors.secondary;
      case AppColorKey.success:
        return AppColors.success;
      case AppColorKey.warning:
        return AppColors.warning;
      case AppColorKey.error:
        return AppColors.error;
      case AppColorKey.onSurfaceMuted:
        return AppColors.onSurfaceMuted;
      case AppColorKey.text:
        return Colors.black87;
    }
  }

  static TextStyle headline({
    required BuildContext context,
    required AppColorKey colorKey,
  }) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: _color(context, colorKey),
    );
  }

  static TextStyle title({
    required BuildContext context,
    required AppColorKey colorKey,
  }) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: _color(context, colorKey),
    );
  }

  static TextStyle body({
    required BuildContext context,
    required AppColorKey colorKey,
  }) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: _color(context, colorKey),
    );
  }

  static TextStyle caption({
    required BuildContext context,
    required AppColorKey colorKey,
  }) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: _color(context, colorKey),
    );
  }

  static TextStyle small({
    required BuildContext context,
    required AppColorKey colorKey,
  }) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: _color(context, colorKey),
    );
  }
}

abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

abstract class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.success,
      error: AppColors.error,
      surface: AppColors.surface,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF94A3B8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: AppColors.border,
    );
  }
}
