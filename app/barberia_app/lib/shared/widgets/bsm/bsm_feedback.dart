import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import 'bsm_button.dart';

enum BsmBannerTone { info, success, warning, danger, brass }

/// Aviso en línea: sesión por expirar (`warning`), reprogramando (`info`),
/// error de carga con «Reintentar» (`danger`).
class BsmBanner extends StatelessWidget {
  const BsmBanner({super.key, this.tone = BsmBannerTone.info, this.title, this.body, this.icon, this.actionLabel, this.onAction});

  final BsmBannerTone tone;
  final String? title;
  final String? body;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (Color fg, Color bg, IconData defaultIcon) = switch (tone) {
      BsmBannerTone.info => (p.info, p.infoBg, LucideIcons.info),
      BsmBannerTone.success => (p.success, p.successBg, LucideIcons.circleCheck),
      BsmBannerTone.warning => (p.warning, p.warningBg, LucideIcons.triangleAlert),
      BsmBannerTone.danger => (p.danger, p.dangerBg, LucideIcons.circleAlert),
      BsmBannerTone.brass => (p.brassInk, p.brassSoft, LucideIcons.timer),
    };
    return Semantics(
      liveRegion: tone == BsmBannerTone.danger || tone == BsmBannerTone.warning,
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s3, AppSpace.s2, AppSpace.s3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon ?? defaultIcon, size: 20, color: fg)),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) Text(title!, style: AppTextStyles.label.copyWith(color: p.ink)),
                  if (body != null) ...[
                    if (title != null) const SizedBox(height: 2),
                    Text(body!, style: AppTextStyles.body.copyWith(color: p.ink)),
                  ],
                ],
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: fg, minimumSize: const Size(44, 36)),
                child: Text(actionLabel!, style: AppTextStyles.weight(AppTextStyles.body, FontWeight.w700).copyWith(decoration: TextDecoration.underline)),
              )
            else
              const SizedBox(width: AppSpace.s2),
          ],
        ),
      ),
    );
  }
}

/// Vacío o error con siguiente paso: «Aún no tienes citas» + «Reservar»;
/// error: «No pudimos cargar …» + «Reintentar».
class BsmEmptyState extends StatelessWidget {
  const BsmEmptyState({
    super.key,
    required this.title,
    this.body,
    this.icon,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.isError = false,
    this.actionVariant,
  });

  final String title;
  final String? body;
  final IconData? icon;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool isError;
  final BsmButtonVariant? actionVariant;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s6, vertical: AppSpace.s10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isError ? p.dangerBg : p.brassSoft),
                child: Icon(icon ?? (isError ? LucideIcons.wifiOff : LucideIcons.calendar), size: 28, color: isError ? p.danger : p.brassInk),
              ),
              const SizedBox(height: AppSpace.s4),
              Text(title, textAlign: TextAlign.center, style: AppTextStyles.titleSm.copyWith(color: p.ink)),
              if (body != null) ...[
                const SizedBox(height: AppSpace.s1),
                Text(body!, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: AppSpace.s5),
                BsmButton(
                  label: actionLabel!,
                  icon: actionIcon,
                  onPressed: onAction,
                  variant: actionVariant ?? (isError ? BsmButtonVariant.secondary : BsmButtonVariant.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum BsmSkeletonVariant { text, card, slots }

/// Marcadores con la forma del contenido real; sin brillo con «reducir movimiento».
/// Mostrar tras 300 ms de espera; nunca un spinner de pantalla completa.
class BsmSkeleton extends StatelessWidget {
  const BsmSkeleton({super.key, this.variant = BsmSkeletonVariant.text, this.count = 1});

  final BsmSkeletonVariant variant;
  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget bone(double? w, double h, {double r = AppRadius.xs}) =>
        Container(width: w, height: h, decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(r)));

    Widget one() => switch (variant) {
          BsmSkeletonVariant.card => Container(
              padding: const EdgeInsets.all(AppSpace.s4),
              decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.line), borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(
                children: [
                  bone(48, 48, r: AppRadius.sm),
                  const SizedBox(width: AppSpace.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(widthFactor: 0.6, child: bone(null, 16)),
                        const SizedBox(height: 10),
                        FractionallySizedBox(widthFactor: 0.9, child: bone(null, 12)),
                        const SizedBox(height: 10),
                        FractionallySizedBox(widthFactor: 0.4, child: bone(null, 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          BsmSkeletonVariant.slots => Wrap(
              spacing: AppSpace.s2,
              runSpacing: AppSpace.s2,
              children: [for (var i = 0; i < 8; i++) bone(76, 44, r: AppRadius.sm)],
            ),
          BsmSkeletonVariant.text => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(widthFactor: 0.7, child: bone(null, 14)),
                const SizedBox(height: 10),
                bone(double.infinity, 14),
                const SizedBox(height: 10),
                FractionallySizedBox(widthFactor: 0.55, child: bone(null, 14)),
              ],
            ),
        };

    return Semantics(
      label: 'Cargando',
      child: Shimmer.fromColors(
        baseColor: p.surfaceSunken,
        highlightColor: p.line,
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < count; i++) ...[if (i > 0) const SizedBox(height: AppSpace.s3), one()],
          ],
        ),
      ),
    );
  }
}

enum BsmConfirmTone { danger, info }

/// Confirmación: el título pregunta, el cuerpo dice qué se pierde y el botón
/// repite el verbo («¿Cancelar esta cita?» → «Sí, cancelar cita»). Nunca «Aceptar».
Future<bool> showBsmConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String cancelLabel = 'Volver',
  BsmConfirmTone tone = BsmConfirmTone.danger,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final p = ctx.palette;
      final danger = tone == BsmConfirmTone.danger;
      return Dialog(
        insetPadding: const EdgeInsets.all(AppSpace.s6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: danger ? p.dangerBg : p.infoBg),
                  child: Icon(icon ?? (danger ? LucideIcons.triangleAlert : LucideIcons.info), size: 24, color: danger ? p.danger : p.info),
                ),
                const SizedBox(height: AppSpace.s4),
                Text(title, style: AppTextStyles.title.copyWith(color: p.ink)),
                const SizedBox(height: AppSpace.s2),
                Text(body, style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted, fontSize: 15, height: 22 / 15)),
                const SizedBox(height: AppSpace.s6),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpace.s2,
                  runSpacing: AppSpace.s2,
                  children: [
                    BsmButton(label: cancelLabel, variant: BsmButtonVariant.secondary, onPressed: () => Navigator.of(ctx).pop(false)),
                    BsmButton(
                      label: confirmLabel,
                      variant: danger ? BsmButtonVariant.danger : BsmButtonVariant.primary,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

enum BsmToastTone { success, danger, info, warning }

/// Toast en `inverse`: 4 s (6 s con acción), uno a la vez, sobre la barra inferior.
/// Errores que bloquean van en BsmBanner, no aquí.
void showBsmToast(
  BuildContext context,
  String message, {
  BsmToastTone tone = BsmToastTone.success,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final p = context.palette;
  final icon = switch (tone) {
    BsmToastTone.success => LucideIcons.circleCheck,
    BsmToastTone.danger => LucideIcons.circleAlert,
    BsmToastTone.info => LucideIcons.info,
    BsmToastTone.warning => LucideIcons.triangleAlert,
  };
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: Duration(seconds: actionLabel != null ? 6 : 4),
      content: Row(
        children: [
          Icon(icon, size: 20, color: p.onInverse),
          const SizedBox(width: AppSpace.s3),
          Expanded(child: Text(message, style: AppTextStyles.bodyLg.copyWith(color: p.onInverse, fontSize: 15))),
        ],
      ),
      action: actionLabel == null ? null : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
    ),
  );
}

/// Formulario en bottom sheet (Modal en móvil): radio superior `xl` con asa.
Future<T?> showBsmSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget child,
  List<Widget> actions = const [],
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final p = ctx.palette;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.s5, 0, AppSpace.s5, AppSpace.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppTextStyles.titleLg.copyWith(color: p.ink)),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpace.s1),
                Text(subtitle, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
              ],
              const SizedBox(height: AppSpace.s4),
              child,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: AppSpace.s6),
                Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpace.s2),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class BsmNavItem {
  const BsmNavItem({required this.icon, required this.label, this.badge = false});

  final IconData icon;
  final String label;

  /// Punto granate de novedad.
  final bool badge;
}

/// Barra inferior de la app: Inicio · Reservar · Mis citas · Perfil.
/// Se oculta durante los pasos 2–4 de la reserva.
class BsmBottomNav extends StatelessWidget {
  const BsmBottomNav({super.key, required this.items, required this.selectedIndex, required this.onSelected});

  final List<BsmNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Destinos por defecto del cliente (design/docs/02-patrones.md).
  static const clientItems = [
    BsmNavItem(icon: LucideIcons.house, label: 'Inicio'),
    BsmNavItem(icon: LucideIcons.calendarPlus, label: 'Reservar'),
    BsmNavItem(icon: LucideIcons.calendarDays, label: 'Mis citas'),
    BsmNavItem(icon: LucideIcons.userRound, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: p.line))),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: [
          for (final it in items)
            NavigationDestination(
              icon: Badge(isLabelVisible: it.badge, smallSize: 8, backgroundColor: p.oxblood, child: Icon(it.icon)),
              label: it.label,
            ),
        ],
      ),
    );
  }
}
