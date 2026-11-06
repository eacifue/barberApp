// BarberShop Medellín — sistema de diseño. Generado de design/docs/04-implementacion.md
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppRadius { static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0, xl = 24.0; }
class AppSpace { static const s1 = 4.0, s2 = 8.0, s3 = 12.0, s4 = 16.0, s5 = 20.0, s6 = 24.0, s8 = 32.0, s10 = 40.0, s12 = 48.0, s16 = 64.0; }
class AppDuration { static const fast = Duration(milliseconds: 120), base = Duration(milliseconds: 200), slow = Duration(milliseconds: 320); }
class AppEasing {
  static const standard = Cubic(0.2, 0, 0, 1);
  static const enter = Cubic(0.05, 0.7, 0.1, 1);
  static const exit = Cubic(0.3, 0, 0.8, 0.15);
}

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.light ? AppPalette.light : AppPalette.dark;
  final scheme = ColorScheme(
    brightness: b,
    primary: p.brass, onPrimary: p.onBrass,
    primaryContainer: p.brassSoft, onPrimaryContainer: p.ink,
    secondary: p.brassInk, onSecondary: p.surface,
    secondaryContainer: p.brassSoft, onSecondaryContainer: p.brassInk,
    tertiary: p.oxblood, onTertiary: b == Brightness.light ? p.ivory : p.carbon,
    tertiaryContainer: p.oxbloodSoft, onTertiaryContainer: p.oxblood,
    error: p.danger, onError: p.onDanger, errorContainer: p.dangerBg, onErrorContainer: p.danger,
    surface: p.surface, onSurface: p.ink, onSurfaceVariant: p.inkMuted,
    surfaceContainerLowest: p.surfaceRaised, surfaceContainerLow: p.surface, surfaceContainer: p.bg,
    surfaceContainerHigh: p.surfaceSunken, surfaceContainerHighest: p.neutralBg,
    outline: p.lineStrong, outlineVariant: p.line,
    inverseSurface: p.inverse, onInverseSurface: p.onInverse, inversePrimary: p.inverseAction,
    scrim: p.scrim, shadow: Colors.black, surfaceTint: Colors.transparent,
  );
  final text = AppTextStyles.textTheme(p.ink);
  final controlShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm));
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: c, width: w));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    textTheme: text,
    extensions: [p],
    splashFactory: InkSparkle.splashFactory,
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: p.brass, foregroundColor: p.onBrass,
      disabledBackgroundColor: p.surfaceSunken, disabledForegroundColor: p.inkDisabled,
      minimumSize: const Size(64, 44), shape: controlShape, textStyle: AppTextStyles.label)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: p.ink, side: BorderSide(color: p.lineStrong),
      minimumSize: const Size(64, 44), shape: controlShape, textStyle: AppTextStyles.label)),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
      foregroundColor: p.brassInk, minimumSize: const Size(44, 44), shape: controlShape, textStyle: AppTextStyles.label)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: p.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border(p.lineStrong), enabledBorder: border(p.lineStrong),
      focusedBorder: border(p.focus, 2), errorBorder: border(p.danger), focusedErrorBorder: border(p.danger, 2),
      disabledBorder: border(p.line),
      hintStyle: text.bodyLarge!.copyWith(color: p.inkMuted),
      helperStyle: text.bodySmall!.copyWith(color: p.inkMuted),
      errorStyle: text.bodySmall!.copyWith(color: p.danger)),
    cardTheme: CardThemeData(color: p.surface, elevation: 0, margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md), side: BorderSide(color: p.line))),
    chipTheme: ChipThemeData(backgroundColor: p.surface, selectedColor: p.brassSoft, checkmarkColor: p.brassInk,
      side: BorderSide(color: p.lineStrong), shape: const StadiumBorder(), labelStyle: AppTextStyles.labelSm.copyWith(color: p.ink)),
    navigationBarTheme: NavigationBarThemeData(height: 72, backgroundColor: p.surface, indicatorColor: p.brassSoft,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(size: 24, color: s.contains(WidgetState.selected) ? p.brassInk : p.inkMuted)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => AppTextStyles.weight(AppTextStyles.caption, FontWeight.w600).copyWith(color: s.contains(WidgetState.selected) ? p.ink : p.inkMuted))),
    tabBarTheme: TabBarThemeData(indicatorColor: p.brass, labelColor: p.ink, unselectedLabelColor: p.inkMuted, labelStyle: AppTextStyles.label, dividerColor: p.line),
    dialogTheme: DialogThemeData(backgroundColor: p.surfaceRaised, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg))),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.surfaceRaised, showDragHandle: true, dragHandleColor: p.lineStrong,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)))),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: p.inverse, actionTextColor: p.inverseAction,
      contentTextStyle: text.bodyLarge!.copyWith(color: p.onInverse), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg))),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.brass : p.surfaceSunken),
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.onBrass : p.inkMuted),
      trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.brass : p.lineStrong)),
    datePickerTheme: DatePickerThemeData(backgroundColor: p.surfaceRaised, todayBorder: BorderSide(color: p.brassInk, width: 1.5),
      dayBackgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.brass : null),
      dayForegroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.onBrass : s.contains(WidgetState.disabled) ? p.inkDisabled : p.ink)),
    dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
  );
}
