import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';

enum BsmButtonVariant { primary, secondary, ghost, danger, dangerGhost }

enum BsmButtonSize { sm, md, lg }

/// Botón del sistema (design/docs/componentes/Button.md).
///
/// - Un solo primario por pantalla; en móvil el CTA de pantalla es `lg` + `block`.
/// - Etiqueta en tipo oración con verbo («Reservar ahora»), nunca MAYÚSCULAS.
/// - `loading` conserva el color, muestra la etiqueta en gerundio y bloquea el doble toque.
/// - Lo destructivo va en dos pasos: `dangerGhost` abre la confirmación; `danger` vive en el diálogo.
class BsmButton extends StatelessWidget {
  const BsmButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BsmButtonVariant.primary,
    this.size = BsmButtonSize.md,
    this.icon,
    this.iconRight,
    this.loading = false,
    this.block = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final BsmButtonVariant variant;
  final BsmButtonSize size;
  final IconData? icon;
  final IconData? iconRight;
  final bool loading;
  final bool block;

  double get _height => switch (size) {
        BsmButtonSize.sm => 36,
        BsmButtonSize.md => 44,
        BsmButtonSize.lg => 52,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final iconSize = size == BsmButtonSize.sm ? 16.0 : 20.0;
    final enabled = onPressed != null;

    final (Color bg, Color fg, BorderSide? side) = switch (variant) {
      BsmButtonVariant.primary => (p.brass, p.onBrass, null),
      BsmButtonVariant.secondary => (p.surface, p.ink, BorderSide(color: p.lineStrong)),
      BsmButtonVariant.ghost => (Colors.transparent, p.brassInk, null),
      BsmButtonVariant.danger => (p.danger, p.onDanger, null),
      BsmButtonVariant.dangerGhost => (Colors.transparent, p.danger, null),
    };
    final filled = variant == BsmButtonVariant.primary || variant == BsmButtonVariant.danger;
    final hover = variant == BsmButtonVariant.primary ? p.brassStrong : null;

    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.disabled) && !loading) return filled ? p.surfaceSunken : bg;
        if (hover != null && (s.contains(WidgetState.hovered) || s.contains(WidgetState.pressed))) return hover;
        return bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled) && !loading ? p.inkDisabled : fg,
      ),
      overlayColor: WidgetStateProperty.all(fg.withValues(alpha: 0.08)),
      side: side == null
          ? null
          : WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.disabled) && !loading ? BorderSide(color: p.line) : side,
            ),
      minimumSize: WidgetStateProperty.all(Size(block ? double.infinity : 64, _height)),
      padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: size == BsmButtonSize.sm ? 12 : 20)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm))),
      textStyle: WidgetStateProperty.all(AppTextStyles.label),
      elevation: WidgetStateProperty.all(0),
      iconSize: WidgetStateProperty.all(iconSize),
    );

    final leading = loading
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : (icon != null ? Icon(icon) : null);

    final child = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: AppSpace.s2)],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1)),
        if (iconRight != null && !loading) ...[const SizedBox(width: AppSpace.s2), Icon(iconRight)],
      ],
    );

    // En carga el botón sigue «habilitado» para conservar el color, pero ignora los toques.
    final VoidCallback? handler = loading ? (enabled ? () {} : null) : onPressed;

    return Semantics(
      button: true,
      enabled: enabled && !loading,
      child: TextButton(onPressed: handler, style: style, child: child),
    );
  }
}

/// Botón de solo ícono, 44 × 44, con etiqueta accesible obligatoria (tooltip).
class BsmIconButton extends StatelessWidget {
  const BsmIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.badge = false,
  });

  final IconData icon;

  /// Nombra la acción y el registro: «Editar Laura Henao».
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;

  /// Punto granate de novedad.
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      style: IconButton.styleFrom(
        foregroundColor: p.ink,
        side: secondary ? BorderSide(color: p.lineStrong) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
      icon: Badge(
        isLabelVisible: badge,
        smallSize: 8,
        backgroundColor: p.oxblood,
        child: Icon(icon, size: 20),
      ),
    );
  }
}
