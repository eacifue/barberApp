import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final headlineLarge = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static final headlineMedium = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static final titleLarge = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static final bodyLarge = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static final bodyMedium = GoogleFonts.inter(
    color: AppColors.textMuted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static final labelLarge = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
