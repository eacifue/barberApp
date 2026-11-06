import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../format/formato.dart';
import 'appointment_status.dart';

enum BsmTone { neutral, brass, success, warning, danger, info, oxblood }

(Color fg, Color bg) toneColors(AppPalette p, BsmTone tone) => switch (tone) {
      BsmTone.neutral => (p.neutral, p.neutralBg),
      BsmTone.brass => (p.brassInk, p.brassSoft),
      BsmTone.success => (p.success, p.successBg),
      BsmTone.warning => (p.warning, p.warningBg),
      BsmTone.danger => (p.danger, p.dangerBg),
      BsmTone.info => (p.info, p.infoBg),
      BsmTone.oxblood => (p.oxblood, p.oxbloodSoft),
    };

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.fg, required this.bg, this.icon});

  final String label;
  final Color fg;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s2, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.xs)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: AppSpace.s1)],
          Flexible(child: Text(label, style: AppTextStyles.labelSm.copyWith(color: fg), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// Estado de cita: color del estado + ícono + palabra.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return _Pill(label: status.label, icon: status.icon, fg: status.color(p), bg: status.background(p));
  }
}

/// Etiqueta corta (Activo, Inactivo, Popular). `oxblood` solo para Popular / Recomendado.
class BsmBadge extends StatelessWidget {
  const BsmBadge(this.label, {super.key, this.tone = BsmTone.neutral, this.icon});

  final String label;
  final BsmTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = toneColors(context.palette, tone);
    return _Pill(label: label, icon: icon, fg: fg, bg: bg);
  }
}

/// Etiqueta informativa (especialidades): sin borde sobre `surface-sunken`. Máximo 3 en tarjetas.
class BsmTag extends StatelessWidget {
  const BsmTag(this.label, {super.key, this.onSurface = false});

  final String label;

  /// Sobre una tarjeta seleccionada (`brass-soft`) usa `surface`.
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s2),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: onSurface ? p.surface : p.surfaceSunken, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: p.inkMuted)),
    );
  }
}

/// Chip de filtro («Todos» primero) con check al elegir.
class BsmFilterChip extends StatelessWidget {
  const BsmFilterChip({super.key, required this.label, required this.selected, required this.onSelected, this.count, this.icon});

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final int? count;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FilterChip(
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      avatar: !selected && icon != null ? Icon(icon, size: 16, color: p.ink) : null,
      side: BorderSide(color: selected ? p.brassInk : p.lineStrong),
      label: Text.rich(
        TextSpan(
          text: label,
          children: [
            if (count != null)
              TextSpan(
                text: '  $count',
                style: AppTextStyles.weight(AppTextStyles.labelSm, FontWeight.w500).copyWith(
                  color: p.inkMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chip de entrada (especialidades): se quita con la «x». Nunca texto separado por comas.
class BsmInputChip extends StatelessWidget {
  const BsmInputChip({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InputChip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIcon: Icon(LucideIcons.x, size: 16, color: p.inkMuted),
      deleteButtonTooltipMessage: 'Quitar $label',
    );
  }
}

const _starPath =
    'M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z';

String _hex(Color c) {
  final argb = c.toARGB32();
  return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

/// Estrella de Lucide rellena (la fuente de Lucide solo trae trazo).
class BsmStar extends StatelessWidget {
  const BsmStar({super.key, required this.color, this.size = 16, this.filled = true});

  final Color color;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = _hex(color);
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="$_starPath" '
        'fill="${filled ? c : 'none'}" stroke="$c" stroke-width="2" stroke-linejoin="round"/></svg>';
    return SvgPicture.string(svg, width: size, height: size, excludeFromSemantics: true);
  }
}

/// Calificación 0–5 con estrellas `brass-ink`, promedio con coma y reseñas.
/// Sin reseñas muestra «Nuevo» en vez de 0,0.
class BsmRating extends StatelessWidget {
  const BsmRating({super.key, required this.value, this.count, this.compact = false, this.size = 16});

  final double? value;
  final int? count;
  final bool compact;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final v = value;
    if (v == null || (v == 0 && (count ?? 0) == 0)) return const BsmBadge('Nuevo', tone: BsmTone.brass);
    final txt = Formato.decimal(v);
    final stars = <Widget>[];
    if (compact) {
      stars.add(BsmStar(color: p.brassInk, size: size));
    } else {
      for (var i = 1; i <= 5; i++) {
        final full = v >= i - 0.25;
        final half = !full && v >= i - 0.75;
        stars.add(
          Stack(
            children: [
              BsmStar(color: p.lineStrong, size: size, filled: true),
              if (full) BsmStar(color: p.brassInk, size: size),
              if (half)
                ClipRect(
                  child: Align(alignment: Alignment.centerLeft, widthFactor: 0.5, child: BsmStar(color: p.brassInk, size: size)),
                ),
            ],
          ),
        );
      }
    }
    return Semantics(
      label: 'Calificación $txt de 5${count != null ? ', $count reseñas' : ''}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in stars) Padding(padding: const EdgeInsets.only(right: 2), child: s),
          const SizedBox(width: 2),
          Text(txt, style: AppTextStyles.labelSm.copyWith(color: p.ink)),
          if (count != null) Text(' ($count)', style: AppTextStyles.caption.copyWith(color: p.inkMuted)),
        ],
      ),
    );
  }
}

/// Foto circular; sin foto (o si falla), iniciales en Gloock sobre `brass-soft`.
class BsmAvatar extends StatelessWidget {
  const BsmAvatar({super.key, required this.name, this.photoUrl, this.size = 48, this.available});

  final String name;
  final String? photoUrl;
  final double size;

  /// Punto de disponible hoy (`true`) / no disponible (`false`).
  final bool? available;

  String get _initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initials = Center(
      child: Text(
        _initials,
        style: AppTextStyles.titleLg.copyWith(fontSize: size * 0.38, height: 1, color: p.brassInk),
      ),
    );
    final url = photoUrl;
    return Semantics(
      label: name,
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: Container(
                width: size,
                height: size,
                color: p.brassSoft,
                child: url == null || url.isEmpty
                    ? initials
                    : CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        width: size,
                        height: size,
                        placeholder: (context, url) => Container(color: p.surfaceSunken),
                        errorWidget: (context, url, error) => initials,
                      ),
              ),
            ),
            if (available != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: available! ? p.success : p.inkDisabled,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Marca: el Portal. En la app, el emblema solo en splash y éxito; no en cada topbar.
class BsmLogo extends StatelessWidget {
  const BsmLogo({super.key, this.horizontal = false, this.height, this.onDark});

  final bool horizontal;
  final double? height;

  /// `null` sigue el tema; `true` fuerza la versión para fondos oscuros (p. ej. sobre `carbon`).
  final bool? onDark;

  @override
  Widget build(BuildContext context) {
    final dark = onDark ?? Theme.of(context).brightness == Brightness.dark;
    final asset = horizontal
        ? (dark ? 'assets/images/logo_horizontal_sobre_oscuro.svg' : 'assets/images/logo_horizontal.svg')
        : (dark ? 'assets/images/logo_mark_sobre_oscuro.svg' : 'assets/images/logo_mark.svg');
    return SvgPicture.asset(asset, height: height ?? (horizontal ? 40 : 48), semanticsLabel: 'BarberShop Medellín');
  }
}

/// Ícono de reloj + texto atenuado (duración, horario).
class BsmMeta extends StatelessWidget {
  const BsmMeta({super.key, required this.text, this.icon = LucideIcons.clock});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: p.inkMuted),
        const SizedBox(width: AppSpace.s1),
        Flexible(child: Text(text, style: AppTextStyles.body.copyWith(color: p.inkMuted))),
      ],
    );
  }
}
