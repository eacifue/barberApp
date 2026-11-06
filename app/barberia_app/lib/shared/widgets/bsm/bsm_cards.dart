import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../format/formato.dart';
import '../service_type_icon.dart';
import 'appointment_status.dart';
import 'bsm_badges.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Contenedor de tarjeta: `surface` + borde `line`, sin sombra. Seleccionada:
/// `brass-soft` + borde `brass-ink` 2 px + check en latón (nunca barra lateral).
class BsmCardFrame extends StatelessWidget {
  const BsmCardFrame({super.key, required this.child, this.selected = false, this.onTap, this.padding = const EdgeInsets.all(AppSpace.s4)});

  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(AppRadius.md);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: selected ? p.brassSoft : p.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: selected ? p.brassInk : p.line, width: selected ? 2 : 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              // Compensa el borde de 2 px para que el contenido no salte al seleccionar.
              padding: selected ? padding - const EdgeInsets.all(1) : padding,
              child: child,
            ),
          ),
        ),
        if (selected)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: p.brass, shape: BoxShape.circle, border: Border.all(color: p.bg, width: 2)),
              child: Icon(LucideIcons.check, size: 14, color: p.onBrass),
            ),
          ),
      ],
    );
  }
}

/// Servicio seleccionable del paso 1: tipo, nombre, descripción, duración y precio.
/// Va dentro de un grupo de opción única.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.name,
    required this.type,
    required this.durationMinutes,
    required this.price,
    this.description,
    this.tag,
    this.selected = false,
    this.onTap,
  });

  final String name;
  final String type;
  final int durationMinutes;
  final num price;
  final String? description;

  /// p. ej. «Popular».
  final String? tag;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '$name, ${Formato.duracion(durationMinutes)}, ${Formato.dinero(price)}',
      excludeSemantics: true,
      child: BsmCardFrame(
        selected: selected,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceTypeBadge(tipo: type, background: selected ? p.surface : null),
            const SizedBox(width: AppSpace.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(name, style: AppTextStyles.titleSm.copyWith(color: p.ink))),
                      if (tag != null) ...[const SizedBox(width: AppSpace.s2), BsmBadge(tag!, tone: BsmTone.oxblood)],
                    ],
                  ),
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(description!, style: AppTextStyles.body.copyWith(color: p.inkMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: AppSpace.s2),
                  Row(
                    children: [
                      Expanded(child: BsmMeta(text: Formato.duracion(durationMinutes))),
                      Text(Formato.dinero(price), style: AppTextStyles.titleSm.copyWith(color: p.ink, fontFeatures: _tabular)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barbero del paso 2: foto, nombre, calificación, experiencia y hasta 3 especialidades.
/// No disponible: al final de la lista, en gris, con motivo y sin poder elegirse.
class BarberCard extends StatelessWidget {
  const BarberCard({
    super.key,
    required this.name,
    required this.years,
    this.photoUrl,
    this.rating,
    this.reviews,
    this.specialties = const [],
    this.available = true,
    this.unavailableLabel,
    this.specialPrice,
    this.selected = false,
    this.onTap,
    this.onProfile,
  });

  final String name;
  final int years;
  final String? photoUrl;
  final double? rating;
  final int? reviews;
  final List<String> specialties;
  final bool available;

  /// p. ej. «Vuelve el lunes».
  final String? unavailableLabel;

  /// Precio especial del barbero para el servicio elegido.
  final num? specialPrice;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final experience = '$years ${years == 1 ? 'año' : 'años'} de experiencia${specialPrice != null ? ' · ${Formato.dinero(specialPrice!)}' : ''}';
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BsmAvatar(name: name, photoUrl: photoUrl, size: 64),
        const SizedBox(width: AppSpace.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.titleSm.copyWith(color: available ? p.ink : p.inkMuted)),
              const SizedBox(height: 2),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpace.s2,
                runSpacing: 2,
                children: [
                  BsmRating(value: rating, count: reviews, compact: true),
                  Text(experience, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                ],
              ),
              if (specialties.isNotEmpty) ...[
                const SizedBox(height: AppSpace.s2),
                Wrap(spacing: 6, runSpacing: 6, children: [for (final s in specialties.take(3)) BsmTag(s, onSurface: selected)]),
              ],
              if (!available) ...[
                const SizedBox(height: AppSpace.s2),
                BsmBadge(unavailableLabel ?? 'No disponible hoy', icon: LucideIcons.calendarX),
              ],
              if (onProfile != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onProfile,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(LucideIcons.chevronRight, size: 16),
                    label: const Text('Ver perfil'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(44, 44)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: available,
      button: true,
      child: Opacity(
        opacity: available ? 1 : 0.72,
        child: BsmCardFrame(selected: selected, onTap: available ? onTap : null, child: content),
      ),
    );
  }
}

/// Cita en Mis citas e Inicio. En Próximas toda la tarjeta abre el detalle (sin
/// botones dentro); el estado va en StatusBadge, nunca en una barra lateral.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.service,
    required this.barber,
    required this.date,
    required this.start,
    required this.end,
    required this.status,
    this.barberPhotoUrl,
    this.price,
    this.onTap,
    this.actions = const [],
  });

  final String service;
  final String barber;
  final DateTime date;
  final DateTime start;
  final DateTime end;
  final AppointmentStatus status;
  final String? barberPhotoUrl;
  final num? price;
  final VoidCallback? onTap;

  /// Botones `sm` (Calificar servicio, Reservar de nuevo, Cómo llegar…).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final small = AppTextStyles.overline.copyWith(color: p.inkMuted, letterSpacing: 0.66);
    return Semantics(
      container: true,
      label: '$service con $barber, ${Formato.fechaLarga(date)}, ${Formato.rango(start, end)}, ${status.label}',
      child: BsmCardFrame(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
                decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: Column(
                  children: [
                    Text(Formato.diaSemana(date).substring(0, 3).toUpperCase(), style: small),
                    Text('${date.day}', style: AppTextStyles.display.copyWith(fontSize: 28, height: 32 / 28, color: p.ink, fontFeatures: _tabular)),
                    Text(Formato.fechaCorta(date).split(' ').last.toUpperCase(), style: small),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpace.s4),
            Expanded(
              child: ExcludeSemantics(
                excluding: actions.isEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(service, style: AppTextStyles.titleSm.copyWith(color: p.ink))),
                        const SizedBox(width: AppSpace.s2),
                        StatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s1),
                    Row(
                      children: [
                        BsmAvatar(name: barber, photoUrl: barberPhotoUrl, size: 24),
                        const SizedBox(width: AppSpace.s2),
                        Expanded(child: Text('con $barber', style: AppTextStyles.body.copyWith(color: p.ink))),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s1),
                    Row(
                      children: [
                        Expanded(child: BsmMeta(text: Formato.rango(start, end))),
                        if (price != null) Text(Formato.dinero(price!), style: AppTextStyles.labelSm.copyWith(color: p.ink, fontFeatures: _tabular)),
                      ],
                    ),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.s3),
                      Divider(color: p.line, height: 1),
                      const SizedBox(height: AppSpace.s2),
                      Wrap(spacing: AppSpace.s2, runSpacing: AppSpace.s2, children: actions),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
