import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand and status colors are tuned to read clearly on both a light
  // paper surface and a dark ink surface, so they stay constant across
  // themes instead of forking into light/dark variants.
  static const primary = Color(0xFFC6A15B);
  static const accent = Color(0xFFC6A15B);
  static const textLight = Color(0xFFFFFFFF);
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFB7791F);
  static const error = Color(0xFFC53030);

  // Light-mode surface/text tokens. Also the values used by any
  // context-free consumer (e.g. domain models, which must not depend on
  // BuildContext/Theme) that needs *a* color without knowing brightness.
  static const secondary = Color(0xFF8E733E);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F3EE);
  static const textMuted = Color(0xFF7B7B7B);
  static const textPrimary = Color(0xFF1E1E1E);

  // Dark-mode counterparts for the tokens above that actually need to flip.
  static const secondaryDark = Color(0xFFD9B876);
  static const surfaceDark = Color(0xFF1E1B17);
  static const backgroundDark = Color(0xFF121110);
  static const textMutedDark = Color(0xFFA9A29A);
  static const textPrimaryDark = Color(0xFFF3EFE7);
  static const shimmerHighlightDark = Color(0xFF2C2823);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color secondaryOf(BuildContext context) =>
      _isDark(context) ? secondaryDark : secondary;

  static Color surfaceOf(BuildContext context) =>
      _isDark(context) ? surfaceDark : surface;

  static Color backgroundOf(BuildContext context) =>
      _isDark(context) ? backgroundDark : background;

  static Color textMutedOf(BuildContext context) =>
      _isDark(context) ? textMutedDark : textMuted;

  static Color textPrimaryOf(BuildContext context) =>
      _isDark(context) ? textPrimaryDark : textPrimary;

  static Color shimmerHighlightOf(BuildContext context) =>
      _isDark(context) ? shimmerHighlightDark : Colors.white;
}
