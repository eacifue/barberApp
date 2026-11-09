import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bsm/bsm.dart';

/// Piezas comunes del admin dentro de la app (design/docs/02-patrones.md):
/// encabezado con acción, filas en tarjeta plana, estados de carga/vacío/error.

/// Mensaje legible de un error del repositorio.
String adminErrorText(Object error, String fallback) => error is AppException && error.message.trim().isNotEmpty ? error.message : fallback;

void adminToastError(BuildContext context, Object error, String fallback) {
  if (!context.mounted) return;
  showBsmToast(context, adminErrorText(error, fallback), tone: BsmToastTone.danger);
}

class AdminLoading extends StatelessWidget {
  const AdminLoading({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(AppSpace.s4),
        children: const [BsmSkeleton(variant: BsmSkeletonVariant.card, count: 4)],
      );
}

class AdminError extends StatelessWidget {
  const AdminError({super.key, required this.title, required this.error, required this.onRetry});

  final String title;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => BsmEmptyState(
        isError: true,
        title: title,
        body: adminErrorText(error, 'Revisa tu conexión e inténtalo de nuevo.'),
        actionLabel: 'Reintentar',
        actionIcon: LucideIcons.refreshCw,
        actionVariant: BsmButtonVariant.secondary,
        onAction: onRetry,
      );
}

/// Título de la sección con conteo y botón principal.
class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key, required this.title, required this.subtitle, this.actionLabel, this.actionIcon = LucideIcons.plus, this.onAction});

  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleLg.copyWith(color: p.ink)),
                const SizedBox(height: AppSpace.s1),
                Text(subtitle, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: AppSpace.s3),
            BsmButton(label: actionLabel!, icon: actionIcon, size: BsmButtonSize.sm, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// Fila de lista: avatar/ícono, título, detalle, insignias y acción de estado.
class AdminRow extends StatelessWidget {
  const AdminRow({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.badges = const [],
    this.inactive = false,
    this.onTap,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final List<Widget> badges;
  final bool inactive;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s3),
      child: Opacity(
        opacity: inactive ? 0.72 : 1,
        child: BsmCardFrame(
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s3, AppSpace.s2, AppSpace.s3),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.label.copyWith(color: p.ink)),
                    const SizedBox(height: 2),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.s2),
                      Wrap(spacing: AppSpace.s1, runSpacing: AppSpace.s1, children: badges),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

BsmBadge adminEstadoBadge(bool activo) =>
    activo ? const BsmBadge('Activo', tone: BsmTone.success, icon: LucideIcons.circleCheck) : const BsmBadge('Inactivo', icon: LucideIcons.ban);

/// Filtro Todos / Activos / Inactivos con conteos.
enum AdminFiltro { todos, activos, inactivos }

class AdminFiltroChips extends StatelessWidget {
  const AdminFiltroChips({super.key, required this.value, required this.onChanged, required this.activos, required this.inactivos});

  final AdminFiltro value;
  final ValueChanged<AdminFiltro> onChanged;
  final int activos;
  final int inactivos;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpace.s4),
        child: Wrap(
          spacing: AppSpace.s2,
          runSpacing: AppSpace.s2,
          children: [
            BsmFilterChip(label: 'Todos', count: activos + inactivos, selected: value == AdminFiltro.todos, onSelected: (_) => onChanged(AdminFiltro.todos)),
            BsmFilterChip(label: 'Activos', count: activos, selected: value == AdminFiltro.activos, onSelected: (_) => onChanged(AdminFiltro.activos)),
            if (inactivos > 0)
              BsmFilterChip(label: 'Inactivos', count: inactivos, selected: value == AdminFiltro.inactivos, onSelected: (_) => onChanged(AdminFiltro.inactivos)),
          ],
        ),
      );
}

bool adminPasaFiltro(AdminFiltro f, bool activo) => switch (f) {
      AdminFiltro.todos => true,
      AdminFiltro.activos => activo,
      AdminFiltro.inactivos => !activo,
    };

/// Validadores de formulario con copy es-CO (design/docs/03-copy.md).
abstract final class AdminValida {
  static String? requerido(String? v, String mensaje) => (v == null || v.trim().isEmpty) ? mensaje : null;

  static String? correo(String? v) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((v ?? '').trim()) ? null : 'Ingresa un correo válido, como nombre@correo.com.';

  static String? telefono(String? v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length < 7 ? 'Ingresa un teléfono de al menos 7 dígitos.' : null;

  static String? url(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    return RegExp(r'^https?://', caseSensitive: false).hasMatch(t) ? null : 'Usa un enlace que empiece por https://';
  }
}
