import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle headlineLarge(Color color) => GoogleFonts.inter(
    color: color,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle headlineMedium(Color color) => GoogleFonts.inter(
    color: color,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static TextStyle titleLarge(Color color) => GoogleFonts.inter(
    color: color,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
    color: color,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
    color: color,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle labelLarge(Color color) => GoogleFonts.inter(
    color: color,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
