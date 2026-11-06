# Implementación

Un solo juego de tokens con los mismos nombres en Flutter y en web. El nombre del token en kebab-case (`brass-ink`) es `brassInk` en Dart y `--brass-ink` en CSS.

## Flutter (Material 3)

Archivos en `app/barberia_app/lib/core/theme/`.

### Fuentes

```yaml
# pubspec.yaml — fuentes empaquetadas (sin descarga en tiempo de ejecución)
flutter:
  fonts:
    - family: Gloock
      fonts:
        - asset: assets/fonts/Gloock-Regular.ttf
    - family: InstrumentSans
      fonts:
        - asset: assets/fonts/InstrumentSans-Variable.ttf
```

Los archivos están en `fonts/` de este sistema (woff2 para web; para Flutter usar los TTF de Google Fonts de las mismas familias). Alternativa: `GoogleFonts.gloock()` y `GoogleFonts.instrumentSans()` con `GoogleFonts.config.allowRuntimeFetching = false` y las fuentes como assets.

### `app_colors.dart` — paleta por tema como `ThemeExtension`

```dart
import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({required this.bg, required this.surface, required this.surfaceRaised, required this.surfaceSunken, required this.line, required this.lineStrong, required this.scrim, required this.ink, required this.inkMuted, required this.inkDisabled, required this.brass, required this.brassStrong, required this.onBrass, required this.brassInk, required this.brassSoft, required this.oxblood, required this.oxbloodSoft, required this.carbon, required this.ivory, required this.inverse, required this.onInverse, required this.inverseAction, required this.success, required this.successBg, required this.warning, required this.warningBg, required this.danger, required this.dangerBg, required this.onDanger, required this.info, required this.infoBg, required this.neutral, required this.neutralBg, required this.statusPendiente, required this.statusPendienteBg, required this.statusConfirmada, required this.statusConfirmadaBg, required this.statusEnprogreso, required this.statusEnprogresoBg, required this.statusCompletada, required this.statusCompletadaBg, required this.statusCancelada, required this.statusCanceladaBg, required this.statusNoshow, required this.statusNoshowBg, required this.slotAvailable, required this.slotBooked, required this.slotBlocked, required this.slotHold, required this.focus, required this.nowLine, required this.chart1, required this.chart2, required this.chart3, required this.chart4, required this.chart5});

  final Color bg;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color line;
  final Color lineStrong;
  final Color scrim;
  final Color ink;
  final Color inkMuted;
  final Color inkDisabled;
  final Color brass;
  final Color brassStrong;
  final Color onBrass;
  final Color brassInk;
  final Color brassSoft;
  final Color oxblood;
  final Color oxbloodSoft;
  final Color carbon;
  final Color ivory;
  final Color inverse;
  final Color onInverse;
  final Color inverseAction;
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color danger;
  final Color dangerBg;
  final Color onDanger;
  final Color info;
  final Color infoBg;
  final Color neutral;
  final Color neutralBg;
  final Color statusPendiente;
  final Color statusPendienteBg;
  final Color statusConfirmada;
  final Color statusConfirmadaBg;
  final Color statusEnprogreso;
  final Color statusEnprogresoBg;
  final Color statusCompletada;
  final Color statusCompletadaBg;
  final Color statusCancelada;
  final Color statusCanceladaBg;
  final Color statusNoshow;
  final Color statusNoshowBg;
  final Color slotAvailable;
  final Color slotBooked;
  final Color slotBlocked;
  final Color slotHold;
  final Color focus;
  final Color nowLine;
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;

  static const light = AppPalette(
    bg: Color(0xFFF6F2EA),
    surface: Color(0xFFFFFDF8),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFEEE8DC),
    line: Color(0xFFE3DACB),
    lineStrong: Color(0xFF8C8172),
    scrim: Color(0x8F14110E),
    ink: Color(0xFF1C1814),
    inkMuted: Color(0xFF675D52),
    inkDisabled: Color(0xFFA99F92),
    brass: Color(0xFFC6A15B),
    brassStrong: Color(0xFFB08A45),
    onBrass: Color(0xFF1C1814),
    brassInk: Color(0xFF7A5C24),
    brassSoft: Color(0xFFF2E7D0),
    oxblood: Color(0xFF7B2D26),
    oxbloodSoft: Color(0xFFF4E3E0),
    carbon: Color(0xFF1C1814),
    ivory: Color(0xFFF6F2EA),
    inverse: Color(0xFF1C1814),
    onInverse: Color(0xFFF4EEE4),
    inverseAction: Color(0xFFC6A15B),
    success: Color(0xFF1A6E44),
    successBg: Color(0xFFE2F2E8),
    warning: Color(0xFFA8460B),
    warningBg: Color(0xFFFCEBDD),
    danger: Color(0xFFB42318),
    dangerBg: Color(0xFFFCE7E5),
    onDanger: Color(0xFFFFFFFF),
    info: Color(0xFF1F5FAD),
    infoBg: Color(0xFFE3EDF9),
    neutral: Color(0xFF675D52),
    neutralBg: Color(0xFFECE6DA),
    statusPendiente: Color(0xFFA8460B),
    statusPendienteBg: Color(0xFFFCEBDD),
    statusConfirmada: Color(0xFF1A6E44),
    statusConfirmadaBg: Color(0xFFE2F2E8),
    statusEnprogreso: Color(0xFF1F5FAD),
    statusEnprogresoBg: Color(0xFFE3EDF9),
    statusCompletada: Color(0xFF7A5C24),
    statusCompletadaBg: Color(0xFFF2E7D0),
    statusCancelada: Color(0xFFB42318),
    statusCanceladaBg: Color(0xFFFCE7E5),
    statusNoshow: Color(0xFF675D52),
    statusNoshowBg: Color(0xFFECE6DA),
    slotAvailable: Color(0xFF1A6E44),
    slotBooked: Color(0xFF675D52),
    slotBlocked: Color(0xFFA8460B),
    slotHold: Color(0xFF1F5FAD),
    focus: Color(0xFF7A5C24),
    nowLine: Color(0xFF7B2D26),
    chart1: Color(0xFFA87A24),
    chart2: Color(0xFF3A6FB8),
    chart3: Color(0xFFB5503C),
    chart4: Color(0xFF8A5BB0),
    chart5: Color(0xFF2F8A5A),
  );
  static const dark = AppPalette(
    bg: Color(0xFF14110E),
    surface: Color(0xFF1D1915),
    surfaceRaised: Color(0xFF27221C),
    surfaceSunken: Color(0xFF0F0D0B),
    line: Color(0xFF352E27),
    lineStrong: Color(0xFF7F7465),
    scrim: Color(0xA3000000),
    ink: Color(0xFFF4EEE4),
    inkMuted: Color(0xFFADA394),
    inkDisabled: Color(0xFF5E554B),
    brass: Color(0xFFC6A15B),
    brassStrong: Color(0xFFD6B677),
    onBrass: Color(0xFF1C1814),
    brassInk: Color(0xFFD9BA7C),
    brassSoft: Color(0xFF2F2718),
    oxblood: Color(0xFFD27A6A),
    oxbloodSoft: Color(0xFF2E1515),
    carbon: Color(0xFF1C1814),
    ivory: Color(0xFFF6F2EA),
    inverse: Color(0xFFF4EEE4),
    onInverse: Color(0xFF1C1814),
    inverseAction: Color(0xFF7A5C24),
    success: Color(0xFF5DC28E),
    successBg: Color(0xFF15281D),
    warning: Color(0xFFF2995A),
    warningBg: Color(0xFF33200F),
    danger: Color(0xFFF47C70),
    dangerBg: Color(0xFF3A1714),
    onDanger: Color(0xFF1C1814),
    info: Color(0xFF7DB0EE),
    infoBg: Color(0xFF13233A),
    neutral: Color(0xFFADA394),
    neutralBg: Color(0xFF2A251F),
    statusPendiente: Color(0xFFF2995A),
    statusPendienteBg: Color(0xFF33200F),
    statusConfirmada: Color(0xFF5DC28E),
    statusConfirmadaBg: Color(0xFF15281D),
    statusEnprogreso: Color(0xFF7DB0EE),
    statusEnprogresoBg: Color(0xFF13233A),
    statusCompletada: Color(0xFFD9BA7C),
    statusCompletadaBg: Color(0xFF2F2718),
    statusCancelada: Color(0xFFF47C70),
    statusCanceladaBg: Color(0xFF3A1714),
    statusNoshow: Color(0xFFADA394),
    statusNoshowBg: Color(0xFF2A251F),
    slotAvailable: Color(0xFF5DC28E),
    slotBooked: Color(0xFFADA394),
    slotBlocked: Color(0xFFF2995A),
    slotHold: Color(0xFF7DB0EE),
    focus: Color(0xFFD9BA7C),
    nowLine: Color(0xFFD27A6A),
    chart1: Color(0xFFB48C3C),
    chart2: Color(0xFF5F94D6),
    chart3: Color(0xFFC9644F),
    chart4: Color(0xFF9B79CB),
    chart5: Color(0xFF3F9E6E),
  );

  @override
  AppPalette copyWith({Color? bg, Color? surface, Color? surfaceRaised, Color? surfaceSunken, Color? line, Color? lineStrong, Color? scrim, Color? ink, Color? inkMuted, Color? inkDisabled, Color? brass, Color? brassStrong, Color? onBrass, Color? brassInk, Color? brassSoft, Color? oxblood, Color? oxbloodSoft, Color? carbon, Color? ivory, Color? inverse, Color? onInverse, Color? inverseAction, Color? success, Color? successBg, Color? warning, Color? warningBg, Color? danger, Color? dangerBg, Color? onDanger, Color? info, Color? infoBg, Color? neutral, Color? neutralBg, Color? statusPendiente, Color? statusPendienteBg, Color? statusConfirmada, Color? statusConfirmadaBg, Color? statusEnprogreso, Color? statusEnprogresoBg, Color? statusCompletada, Color? statusCompletadaBg, Color? statusCancelada, Color? statusCanceladaBg, Color? statusNoshow, Color? statusNoshowBg, Color? slotAvailable, Color? slotBooked, Color? slotBlocked, Color? slotHold, Color? focus, Color? nowLine, Color? chart1, Color? chart2, Color? chart3, Color? chart4, Color? chart5}) => AppPalette(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      scrim: scrim ?? this.scrim,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkDisabled: inkDisabled ?? this.inkDisabled,
      brass: brass ?? this.brass,
      brassStrong: brassStrong ?? this.brassStrong,
      onBrass: onBrass ?? this.onBrass,
      brassInk: brassInk ?? this.brassInk,
      brassSoft: brassSoft ?? this.brassSoft,
      oxblood: oxblood ?? this.oxblood,
      oxbloodSoft: oxbloodSoft ?? this.oxbloodSoft,
      carbon: carbon ?? this.carbon,
      ivory: ivory ?? this.ivory,
      inverse: inverse ?? this.inverse,
      onInverse: onInverse ?? this.onInverse,
      inverseAction: inverseAction ?? this.inverseAction,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      danger: danger ?? this.danger,
      dangerBg: dangerBg ?? this.dangerBg,
      onDanger: onDanger ?? this.onDanger,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      neutral: neutral ?? this.neutral,
      neutralBg: neutralBg ?? this.neutralBg,
      statusPendiente: statusPendiente ?? this.statusPendiente,
      statusPendienteBg: statusPendienteBg ?? this.statusPendienteBg,
      statusConfirmada: statusConfirmada ?? this.statusConfirmada,
      statusConfirmadaBg: statusConfirmadaBg ?? this.statusConfirmadaBg,
      statusEnprogreso: statusEnprogreso ?? this.statusEnprogreso,
      statusEnprogresoBg: statusEnprogresoBg ?? this.statusEnprogresoBg,
      statusCompletada: statusCompletada ?? this.statusCompletada,
      statusCompletadaBg: statusCompletadaBg ?? this.statusCompletadaBg,
      statusCancelada: statusCancelada ?? this.statusCancelada,
      statusCanceladaBg: statusCanceladaBg ?? this.statusCanceladaBg,
      statusNoshow: statusNoshow ?? this.statusNoshow,
      statusNoshowBg: statusNoshowBg ?? this.statusNoshowBg,
      slotAvailable: slotAvailable ?? this.slotAvailable,
      slotBooked: slotBooked ?? this.slotBooked,
      slotBlocked: slotBlocked ?? this.slotBlocked,
      slotHold: slotHold ?? this.slotHold,
      focus: focus ?? this.focus,
      nowLine: nowLine ?? this.nowLine,
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
      chart4: chart4 ?? this.chart4,
      chart5: chart5 ?? this.chart5,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    final o = other;
    return AppPalette(
      bg: Color.lerp(bg, o.bg, t)!,
      surface: Color.lerp(surface, o.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, o.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, o.surfaceSunken, t)!,
      line: Color.lerp(line, o.line, t)!,
      lineStrong: Color.lerp(lineStrong, o.lineStrong, t)!,
      scrim: Color.lerp(scrim, o.scrim, t)!,
      ink: Color.lerp(ink, o.ink, t)!,
      inkMuted: Color.lerp(inkMuted, o.inkMuted, t)!,
      inkDisabled: Color.lerp(inkDisabled, o.inkDisabled, t)!,
      brass: Color.lerp(brass, o.brass, t)!,
      brassStrong: Color.lerp(brassStrong, o.brassStrong, t)!,
      onBrass: Color.lerp(onBrass, o.onBrass, t)!,
      brassInk: Color.lerp(brassInk, o.brassInk, t)!,
      brassSoft: Color.lerp(brassSoft, o.brassSoft, t)!,
      oxblood: Color.lerp(oxblood, o.oxblood, t)!,
      oxbloodSoft: Color.lerp(oxbloodSoft, o.oxbloodSoft, t)!,
      carbon: Color.lerp(carbon, o.carbon, t)!,
      ivory: Color.lerp(ivory, o.ivory, t)!,
      inverse: Color.lerp(inverse, o.inverse, t)!,
      onInverse: Color.lerp(onInverse, o.onInverse, t)!,
      inverseAction: Color.lerp(inverseAction, o.inverseAction, t)!,
      success: Color.lerp(success, o.success, t)!,
      successBg: Color.lerp(successBg, o.successBg, t)!,
      warning: Color.lerp(warning, o.warning, t)!,
      warningBg: Color.lerp(warningBg, o.warningBg, t)!,
      danger: Color.lerp(danger, o.danger, t)!,
      dangerBg: Color.lerp(dangerBg, o.dangerBg, t)!,
      onDanger: Color.lerp(onDanger, o.onDanger, t)!,
      info: Color.lerp(info, o.info, t)!,
      infoBg: Color.lerp(infoBg, o.infoBg, t)!,
      neutral: Color.lerp(neutral, o.neutral, t)!,
      neutralBg: Color.lerp(neutralBg, o.neutralBg, t)!,
      statusPendiente: Color.lerp(statusPendiente, o.statusPendiente, t)!,
      statusPendienteBg: Color.lerp(statusPendienteBg, o.statusPendienteBg, t)!,
      statusConfirmada: Color.lerp(statusConfirmada, o.statusConfirmada, t)!,
      statusConfirmadaBg: Color.lerp(statusConfirmadaBg, o.statusConfirmadaBg, t)!,
      statusEnprogreso: Color.lerp(statusEnprogreso, o.statusEnprogreso, t)!,
      statusEnprogresoBg: Color.lerp(statusEnprogresoBg, o.statusEnprogresoBg, t)!,
      statusCompletada: Color.lerp(statusCompletada, o.statusCompletada, t)!,
      statusCompletadaBg: Color.lerp(statusCompletadaBg, o.statusCompletadaBg, t)!,
      statusCancelada: Color.lerp(statusCancelada, o.statusCancelada, t)!,
      statusCanceladaBg: Color.lerp(statusCanceladaBg, o.statusCanceladaBg, t)!,
      statusNoshow: Color.lerp(statusNoshow, o.statusNoshow, t)!,
      statusNoshowBg: Color.lerp(statusNoshowBg, o.statusNoshowBg, t)!,
      slotAvailable: Color.lerp(slotAvailable, o.slotAvailable, t)!,
      slotBooked: Color.lerp(slotBooked, o.slotBooked, t)!,
      slotBlocked: Color.lerp(slotBlocked, o.slotBlocked, t)!,
      slotHold: Color.lerp(slotHold, o.slotHold, t)!,
      focus: Color.lerp(focus, o.focus, t)!,
      nowLine: Color.lerp(nowLine, o.nowLine, t)!,
      chart1: Color.lerp(chart1, o.chart1, t)!,
      chart2: Color.lerp(chart2, o.chart2, t)!,
      chart3: Color.lerp(chart3, o.chart3, t)!,
      chart4: Color.lerp(chart4, o.chart4, t)!,
      chart5: Color.lerp(chart5, o.chart5, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
```

### `ColorScheme`

| Rol M3 | Token |
|---|---|
| `primary` / `onPrimary` | `brass` / `on-brass` |
| `primaryContainer` / `onPrimaryContainer` | `brass-soft` / `ink` |
| `secondary` / `onSecondary` | `brass-ink` / `surface` |
| `secondaryContainer` / `onSecondaryContainer` | `brass-soft` / `brass-ink` (indicador de `NavigationBar`) |
| `tertiary` / `onTertiary` | `oxblood` / `ivory` (claro) · `carbon` (oscuro) |
| `tertiaryContainer` / `onTertiaryContainer` | `oxblood-soft` / `oxblood` |
| `error` / `onError` | `danger` / `on-danger` |
| `errorContainer` / `onErrorContainer` | `danger-bg` / `danger` |
| `surface` / `onSurface` | `surface` / `ink` |
| `onSurfaceVariant` | `ink-muted` |
| `surfaceContainerLowest` | `surface-raised` |
| `surfaceContainerLow` | `surface` |
| `surfaceContainer` | `bg` |
| `surfaceContainerHigh` | `surface-sunken` |
| `surfaceContainerHighest` | `neutral-bg` |
| `outline` / `outlineVariant` | `line-strong` / `line` |
| `inverseSurface` / `onInverseSurface` / `inversePrimary` | `inverse` / `on-inverse` / `inverse-action` |
| `scrim` | `scrim` |
| `surfaceTint` | `Colors.transparent` (sin tinte de elevación) |

### `app_theme.dart`

```dart
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
      labelTextStyle: WidgetStateProperty.resolveWith((s) => AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: s.contains(WidgetState.selected) ? p.ink : p.inkMuted))),
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
```

Requiere Flutter ≥ 3.27 (`CardThemeData`, `DialogThemeData`, `TabBarThemeData`, `WidgetStateProperty`); en versiones anteriores usa `CardTheme`, `DialogTheme`, `TabBarTheme` y `MaterialStateProperty`.

### `app_text_styles.dart`

| Token | `TextTheme` | Familia · tamaño/alto · peso |
|---|---|---|
| `display-lg` | `displayLarge` | Gloock 40/44 · 400 |
| `kpi` | `displaySmall` | Gloock 36/40 · 400 · tnum |
| `display` | `headlineLarge` | Gloock 32/36 · 400 |
| `title-lg` | `headlineSmall` | Gloock 24/30 · 400 |
| `title` | `titleLarge` | Instrument Sans 20/26 · 600 |
| `title-sm` | `titleMedium` | Instrument Sans 17/24 · 600 |
| `body-lg` | `bodyLarge` | Instrument Sans 16/24 · 400 |
| `body` | `bodyMedium` | Instrument Sans 14/20 · 400 |
| `caption` | `bodySmall` | Instrument Sans 12/16 · 500 |
| `label` | `labelLarge` | Instrument Sans 15/20 · 600 |
| `label-sm` | `labelMedium` | Instrument Sans 13/16 · 600 |
| `overline` | `labelSmall` | Instrument Sans 11/16 · 600 · +0.08em · MAYÚSCULAS |
| `numeric` | `AppTextStyles.numeric` | Instrument Sans 28/32 · 600 · tnum |

```dart
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
```

`MaterialApp(theme: buildTheme(Brightness.light), darkTheme: buildTheme(Brightness.dark), themeMode: ThemeMode.system, locale: const Locale('es', 'CO'))` con `flutter_localizations` e `intl` (`NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0)`).

## Web (React + Tailwind 3)

### `src/globals.css`

Copia el `tokens.css` generado por este sistema (variables bajo `:root, [data-theme="light"]` y `[data-theme="dark"]`) y carga las fuentes:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Gloock&family=Instrument+Sans:wdth,wght@75..100,400..700&display=swap" rel="stylesheet">
```

Tema claro / oscuro / sistema: guarda la elección y aplica `document.documentElement.dataset.theme = elección === 'sistema' ? (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light') : elección`, escuchando el cambio de `matchMedia` cuando la elección es «sistema».

### `tailwind.config.js`

```js
const v = (n) => `var(--${n})`;
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./index.html', './src/**/*.{js,jsx,ts,tsx}'],
  darkMode: ['selector', '[data-theme="dark"]'], // Tailwind ≥ 3.4.1; antes: ['class', '[data-theme="dark"]']
  theme: {
    extend: {
      colors: {
        bg: v('bg'),
        surface: { DEFAULT: v('surface'), raised: v('surface-raised'), sunken: v('surface-sunken') },
        line: { DEFAULT: v('line'), strong: v('line-strong') },
        scrim: v('scrim'),
        ink: { DEFAULT: v('ink'), muted: v('ink-muted'), disabled: v('ink-disabled') },
        brass: { DEFAULT: v('brass'), strong: v('brass-strong'), ink: v('brass-ink'), soft: v('brass-soft'), on: v('on-brass') },
        oxblood: { DEFAULT: v('oxblood'), soft: v('oxblood-soft') },
        carbon: v('carbon'), ivory: v('ivory'),
        inverse: { DEFAULT: v('inverse'), on: v('on-inverse'), action: v('inverse-action') },
        success: { DEFAULT: v('success'), bg: v('success-bg') },
        warning: { DEFAULT: v('warning'), bg: v('warning-bg') },
        danger: { DEFAULT: v('danger'), bg: v('danger-bg'), on: v('on-danger') },
        info: { DEFAULT: v('info'), bg: v('info-bg') },
        neutral: { DEFAULT: v('neutral'), bg: v('neutral-bg') },
        status: {
          pendiente: v('status-pendiente'), 'pendiente-bg': v('status-pendiente-bg'),
          confirmada: v('status-confirmada'), 'confirmada-bg': v('status-confirmada-bg'),
          enprogreso: v('status-enprogreso'), 'enprogreso-bg': v('status-enprogreso-bg'),
          completada: v('status-completada'), 'completada-bg': v('status-completada-bg'),
          cancelada: v('status-cancelada'), 'cancelada-bg': v('status-cancelada-bg'),
          noshow: v('status-noshow'), 'noshow-bg': v('status-noshow-bg'),
        },
        slot: { available: v('slot-available'), booked: v('slot-booked'), blocked: v('slot-blocked'), hold: v('slot-hold') },
        focus: v('focus'), now: v('now-line'),
        chart: { 1: v('chart-1'), 2: v('chart-2'), 3: v('chart-3'), 4: v('chart-4'), 5: v('chart-5') },
      },
      fontFamily: { display: v('font-display'), sans: v('font-sans') },
      fontSize: {
        'display-lg': ['40px', { lineHeight: '44px', letterSpacing: '-0.01em' }],
        display: ['32px', '36px'], 'title-lg': ['24px', '30px'], kpi: ['36px', { lineHeight: '40px', letterSpacing: '-0.01em' }],
        title: ['20px', { lineHeight: '26px', fontWeight: '600' }], 'title-sm': ['17px', { lineHeight: '24px', fontWeight: '600' }],
        'body-lg': ['16px', '24px'], body: ['14px', '20px'],
        label: ['15px', { lineHeight: '20px', fontWeight: '600' }], 'label-sm': ['13px', { lineHeight: '16px', fontWeight: '600' }],
        caption: ['12px', { lineHeight: '16px', fontWeight: '500' }], overline: ['11px', { lineHeight: '16px', letterSpacing: '0.08em', fontWeight: '600' }],
        numeric: ['28px', { lineHeight: '32px', letterSpacing: '-0.01em', fontWeight: '600' }],
      },
      borderRadius: { xs: v('radius-xs'), sm: v('radius-sm'), md: v('radius-md'), lg: v('radius-lg'), xl: v('radius-xl') },
      boxShadow: { sm: v('shadow-sm'), md: v('shadow-md'), lg: v('shadow-lg'), focus: v('focus-ring') },
      height: { 'control-sm': '36px', control: '44px', 'control-lg': '52px', topbar: '64px' },
      width: { sidebar: '264px' },
      transitionDuration: { fast: '120ms', base: '200ms', slow: '320ms' },
      transitionTimingFunction: { standard: 'cubic-bezier(0.2, 0, 0, 1)', enter: 'cubic-bezier(0.05, 0.7, 0.1, 1)', exit: 'cubic-bezier(0.3, 0, 0.8, 0.15)' },
      screens: { sm: '390px', md: '768px', lg: '1280px', xl: '1440px' },
    },
  },
};
```

- La escala de espaciado por defecto de Tailwind ya es base 4 (`p-4` = 16 px = `space-4`); no se redefine.
- Con colores en `var()` los modificadores de opacidad (`bg-brass/50`) no funcionan; para tintes usa los tokens `-soft` / `-bg`.
- Foco: `focus-visible:outline-none focus-visible:shadow-focus` en todo elemento interactivo.
- Reemplaza `gold` (`#B8860B`) y el acento `#8B6F47` por `brass` / `brass-ink`; elimina los paneles semitransparentes y los degradados radiales del fondo.
