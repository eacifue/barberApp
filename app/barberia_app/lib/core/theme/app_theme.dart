import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(
    brightness: Brightness.light,
    background: AppColors.background,
    surface: AppColors.surface,
    secondary: AppColors.secondary,
    textPrimary: AppColors.textPrimary,
    textMuted: AppColors.textMuted,
  );

  static ThemeData get darkTheme => _build(
    brightness: Brightness.dark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    secondary: AppColors.secondaryDark,
    textPrimary: AppColors.textPrimaryDark,
    textMuted: AppColors.textMutedDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color secondary,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: AppColors.primary,
          secondary: secondary,
          surface: surface,
          error: AppColors.error,
          onSurface: textPrimary,
          onPrimary: AppColors.textLight,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge(textPrimary),
        headlineMedium: AppTextStyles.headlineMedium(textPrimary),
        titleLarge: AppTextStyles.titleLarge(textPrimary),
        bodyLarge: AppTextStyles.bodyLarge(textPrimary),
        bodyMedium: AppTextStyles.bodyMedium(textMuted),
        labelLarge: AppTextStyles.labelLarge(textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: textMuted.withValues(alpha: 0.22)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          minimumSize: const Size.fromHeight(44),
          textStyle: AppTextStyles.labelLarge(AppColors.textLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(44),
          side: BorderSide(color: textMuted.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: false,
        labelStyle: AppTextStyles.bodyMedium(textMuted),
        hintStyle: AppTextStyles.bodyMedium(textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: textMuted.withValues(alpha: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: textMuted.withValues(alpha: 0.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        // Snackbars stay on a fixed dark "ink" chip regardless of app
        // theme (matches Material's inverse-surface convention), so the
        // white content text underneath is always legible.
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium(
          AppColors.textLight,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        elevation: 1,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 22);
          }
          return IconThemeData(color: textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.bodyMedium(
              AppColors.primary,
            ).copyWith(fontWeight: FontWeight.w600);
          }
          return AppTextStyles.bodyMedium(textMuted);
        }),
      ),
    );
  }
}
