import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/auth/logout_button.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../domain/models/cita_model.dart';
import '../providers/citas_provider.dart';

DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _lunesDe(DateTime d) => _soloFecha(d).subtract(Duration(days: d.weekday - 1));
int _min(String hhmm) => int.parse(hhmm.substring(0, 2)) * 60 + int.parse(hhmm.substring(3, 5));
String _hora(String hhmm) => Formato.horaDe(int.parse(hhmm.substring(0, 2)), int.parse(hhmm.substring(3, 5)));
bool _cuenta(CitaModel c) {
  final s = AppointmentStatus.fromBackend(c.estado);
  return s != AppointmentStatus.cancelada && s != AppointmentStatus.noShow;
}

/// «Mi agenda» del barbero en la app. Sin diseño propio: patrones de
/// design/docs/02-patrones.md y la agenda móvil del panel. Solo lectura: los
/// cambios de estado los hace recepción (Admin y Admin Barbería en la API).
class AgendaBarberoScreen extends ConsumerStatefulWidget {
  const AgendaBarberoScreen({super.key});

  @override
  ConsumerState<AgendaBarberoScreen> createState() => _AgendaBarberoScreenState();
}

class _AgendaBarberoScreenState extends ConsumerState<AgendaBarberoScreen> {
  late DateTime _dia = _soloFecha(DateTime.now());
  late DateTime _semana = _lunesDe(DateTime.now());

  void _irA(DateTime d) => setState(() {
        _dia = _soloFecha(d);
        _semana = _lunesDe(d);
      });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hoy = _soloFecha(DateTime.now());
    final citasAsync = ref.watch(agendaBarberoProvider(_dia));
    final dias = [for (var i = 0; i < 7; i++) _semana.add(Duration(days: i))];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi agenda'),
        actions: [
          if (_dia != hoy) TextButton(onPressed: () => _irA(hoy), child: const Text('Hoy')),
          const LogoutButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(agendaBarberoProvider(_dia).future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s2, AppSpace.s4, AppSpace.s8),
          children: [
            Row(
              children: [
                BsmIconButton(icon: LucideIcons.chevronLeft, label: 'Semana anterior', onPressed: () => setState(() => _semana = _semana.subtract(const Duration(days: 7)))),
                Expanded(
                  child: Text(
                    '${Formato.fechaCorta(dias.first)} – ${Formato.fechaCorta(dias.last)}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSm.copyWith(color: p.inkMuted),
                  ),
                ),
                BsmIconButton(icon: LucideIcons.chevronRight, label: 'Semana siguiente', onPressed: () => setState(() => _semana = _semana.add(const Duration(days: 7)))),
              ],
            ),
            const SizedBox(height: AppSpace.s2),
            Row(
              children: [
                for (final d in dias)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _DiaChip(fecha: d, seleccionado: d == _dia, esHoy: d == hoy, onTap: () => setState(() => _dia = d)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.s5),
            Text(
              _dia == hoy ? 'Hoy, ${Formato.fechaLarga(_dia)}' : _capitalizar(Formato.fechaLarga(_dia)),
              style: AppTextStyles.titleLg.copyWith(color: p.ink),
            ),
            const SizedBox(height: AppSpace.s1),
            citasAsync.when(
              loading: () => const Padding(padding: EdgeInsets.only(top: AppSpace.s4), child: BsmSkeleton(variant: BsmSkeletonVariant.card, count: 3)),
              error: (e, _) => Padding(
                padding: const EdgeInsets.only(top: AppSpace.s6),
                child: BsmEmptyState(
                  isError: true,
                  title: 'No pudimos cargar tu agenda',
                  body: e is AppException ? e.message : 'Revisa tu conexión e inténtalo de nuevo.',
                  actionLabel: 'Reintentar',
                  actionIcon: LucideIcons.refreshCw,
                  actionVariant: BsmButtonVariant.secondary,
                  onAction: () => ref.invalidate(agendaBarberoProvider(_dia)),
                ),
              ),
              data: (citas) => _Dia(citas: citas, esHoy: _dia == hoy),
            ),
          ],
        ),
      ),
    );
  }
}

String _capitalizar(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class _DiaChip extends StatelessWidget {
  const _DiaChip({required this.fecha, required this.seleccionado, required this.esHoy, required this.onTap});

  final DateTime fecha;
  final bool seleccionado;
  final bool esHoy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      selected: seleccionado,
      label: Formato.fechaLarga(fecha),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
          decoration: BoxDecoration(
            color: seleccionado ? p.brassSoft : p.surface,
            border: Border.all(color: seleccionado ? p.brass : p.line),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(esHoy ? 'Hoy' : _capitalizar(Formato.diaSemana(fecha).substring(0, 3)), style: AppTextStyles.caption.copyWith(color: p.inkMuted)),
                const SizedBox(height: 2),
                Text('${fecha.day}', style: AppTextStyles.titleSm.copyWith(color: p.ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dia extends StatelessWidget {
  const _Dia({required this.citas, required this.esHoy});

  final List<CitaModel> citas;
  final bool esHoy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final activas = citas.where(_cuenta).toList();
    final ahora = TimeOfDay.now();
    final ahoraMin = ahora.hour * 60 + ahora.minute;
    final proxima = esHoy
        ? activas.where((c) {
            final s = AppointmentStatus.fromBackend(c.estado);
            return (s == AppointmentStatus.pendiente || s == AppointmentStatus.confirmada) && _min(c.horaInicio) >= ahoraMin;
          }).firstOrNull
        : null;
    final resumen = activas.isEmpty
        ? 'Sin citas agendadas.'
        : [
            activas.length == 1 ? '1 cita' : '${activas.length} citas',
            if (proxima != null) 'próxima a las ${_hora(proxima.horaInicio)}',
          ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(resumen, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
        const SizedBox(height: AppSpace.s4),
        if (citas.isEmpty)
          const BsmEmptyState(icon: LucideIcons.calendarX, title: 'Día libre de citas', body: 'Cuando un cliente reserve contigo aparecerá aquí.')
        else ...[
          for (final c in citas) _CitaFila(cita: c, destacada: c.id == proxima?.id),
          const SizedBox(height: AppSpace.s2),
          Text('Recepción confirma, inicia y completa tus citas desde el panel.', textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: p.inkMuted)),
        ],
      ],
    );
  }
}

class _CitaFila extends StatelessWidget {
  const _CitaFila({required this.cita, required this.destacada});

  final CitaModel cita;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final estado = AppointmentStatus.fromBackend(cita.estado);
    final apagada = estado == AppointmentStatus.cancelada || estado == AppointmentStatus.noShow;
    final cliente = '${cita.cliente.nombre} ${cita.cliente.apellido}'.trim();
    final telefono = cita.cliente.telefono.replaceAll(RegExp(r'[^\d+]'), '');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s3),
      child: Opacity(
        opacity: apagada ? 0.6 : 1,
        child: BsmCardFrame(
          selected: destacada,
          padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s3, AppSpace.s2, AppSpace.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_hora(cita.horaInicio), style: AppTextStyles.label.copyWith(color: p.ink, decoration: apagada ? TextDecoration.lineThrough : null)),
                    Text(_hora(cita.horaFin), style: AppTextStyles.caption.copyWith(color: p.inkMuted)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.label.copyWith(color: p.ink)),
                    const SizedBox(height: 2),
                    Text('${cita.servicio.nombre} · ${Formato.duracion(cita.servicio.duracionMinutos)}', maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                    const SizedBox(height: AppSpace.s2),
                    Wrap(
                      spacing: AppSpace.s2,
                      runSpacing: AppSpace.s1,
                      children: [
                        StatusBadge(estado),
                        if (destacada) const BsmBadge('Siguiente', tone: BsmTone.brass, icon: LucideIcons.clock),
                      ],
                    ),
                    if ((cita.notas ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpace.s2),
                      Text('Nota: ${cita.notas!.trim()}', style: AppTextStyles.caption.copyWith(color: p.inkMuted)),
                    ],
                  ],
                ),
              ),
              if (telefono.length >= 7 && !apagada)
                BsmIconButton(icon: LucideIcons.phone, label: 'Llamar a $cliente', onPressed: () => launchUrl(Uri(scheme: 'tel', path: telefono))),
            ],
          ),
        ),
      ),
    );
  }
}
