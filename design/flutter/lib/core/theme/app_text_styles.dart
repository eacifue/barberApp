// BarberShop Medellín — sistema de diseño. Generado de design/docs/04-implementacion.md
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class AppTextStyles {
  static const _display = 'Gloock';
  static const _sans = 'InstrumentSans';
  static const _tnum = [FontFeature.tabularFigures()];
  static TextStyle _s(String f, double size, double lh, FontWeight w, {double ls = 0, List<FontFeature>? ff}) =>
      TextStyle(fontFamily: f, fontSize: size, height: lh / size, fontWeight: w, letterSpacing: ls * size, fontFeatures: ff);

  static final displayLg = _s(_display, 40, 44, FontWeight.w400, ls: -0.01);
  static final display = _s(_display, 32, 36, FontWeight.w400);
  static final titleLg = _s(_display, 24, 30, FontWeight.w400);
  static final kpi = _s(_display, 36, 40, FontWeight.w400, ls: -0.01, ff: _tnum);
  static final title = _s(_sans, 20, 26, FontWeight.w600);
  static final titleSm = _s(_sans, 17, 24, FontWeight.w600);
  static final bodyLg = _s(_sans, 16, 24, FontWeight.w400);
  static final body = _s(_sans, 14, 20, FontWeight.w400);
  static final label = _s(_sans, 15, 20, FontWeight.w600);
  static final labelSm = _s(_sans, 13, 16, FontWeight.w600);
  static final caption = _s(_sans, 12, 16, FontWeight.w500);
  static final overline = _s(_sans, 11, 16, FontWeight.w600, ls: 0.08);
  static final numeric = _s(_sans, 28, 32, FontWeight.w600, ls: -0.01, ff: _tnum);

  static TextTheme textTheme(Color ink) => TextTheme(
        displayLarge: displayLg, displaySmall: kpi, headlineLarge: display, headlineSmall: titleLg,
        titleLarge: title, titleMedium: titleSm, bodyLarge: bodyLg, bodyMedium: body, bodySmall: caption,
        labelLarge: label, labelMedium: labelSm, labelSmall: overline,
      ).apply(bodyColor: ink, displayColor: ink);
}
