import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../domain/models/cita_model.dart';
import '../booking_actions.dart';
import '../providers/citas_provider.dart';
import '../widgets/booking_scaffold.dart';

/// Calificar servicio (cita Completada sin reseña): 5 estrellas de 44 px y
/// comentario opcional (design/pantallas/app-movil/Cita-calificar).
class CalificarCitaScreen extends ConsumerStatefulWidget {
  const CalificarCitaScreen({super.key, required this.citaId});

  final String citaId;

  @override
  ConsumerState<CalificarCitaScreen> createState() => _CalificarCitaScreenState();
}

class _CalificarCitaScreenState extends ConsumerState<CalificarCitaScreen> {
  static const _etiquetas = ['Mal', 'Regular', 'Bien', 'Muy bien', 'Excelente'];

  final _comentario = TextEditingController();
  int _estrellas = 0;
  bool _enviando = false;

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _enviar(CitaModel cita) async {
    setState(() => _enviando = true);
    final router = GoRouter.of(context);
    try {
      final texto = _comentario.text.trim();
      await ref.read(citaRepositoryProvider).calificarCita(cita.id, calificacion: _estrellas, comentario: texto.isEmpty ? null : texto);
      ref.invalidate(citaByIdProvider(cita.id));
      final barberiaId = ref.read(myBarbershopProvider).valueOrNull?.id;
      if (barberiaId != null) ref.invalidate(misCitasProvider(barberiaId));
      if (!mounted) return;
      showBsmToast(context, '¡Gracias por tu reseña!');
      router.go('/appointments');
    } catch (e) {
      if (mounted) showBsmToast(context, mensajeDeError(e, 'No pudimos enviar tu reseña. Inténtalo de nuevo.'), tone: BsmToastTone.danger);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final citaAsync = ref.watch(citaByIdProvider(widget.citaId));
    final cita = citaAsync.valueOrNull;

    Widget header(AppointmentStatus? status) => Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.s2, AppSpace.s1, AppSpace.s4, AppSpace.s2),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Volver',
                onPressed: () => context.go('/appointments/${widget.citaId}'),
                icon: const Icon(LucideIcons.arrowLeft, size: 24),
              ),
              const SizedBox(width: AppSpace.s1),
              Expanded(child: Semantics(header: true, child: Text('Tu cita', style: AppTextStyles.display.copyWith(color: p.ink)))),
              if (status != null) StatusBadge(status),
            ],
          ),
        );

    if (cita == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header(null),
              Expanded(
                child: citaAsync.hasError
                    ? BsmEmptyState(
                        isError: true,
                        title: 'No pudimos cargar tu cita',
                        body: 'Revisa tu conexión e inténtalo de nuevo.',
                        actionLabel: 'Reintentar',
                        actionIcon: LucideIcons.refreshCw,
                        onAction: () => ref.invalidate(citaByIdProvider(widget.citaId)),
                      )
                    : const Padding(padding: EdgeInsets.all(AppSpace.s4), child: BsmSkeleton(variant: BsmSkeletonVariant.card)),
              ),
            ],
          ),
        ),
      );
    }

    final status = AppointmentStatus.fromBackend(cita.estado);
    final inicio = fechaConHora(cita.fechaCita, cita.horaInicio);
    final barbero = '${cita.barbero.nombre} ${cita.barbero.apellido}'.trim();
    final puedeCalificar = status == AppointmentStatus.completada && !cita.tieneReview;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s2, AppSpace.s4, AppSpace.s4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (puedeCalificar)
                BsmButton(
                  label: _enviando ? 'Enviando…' : 'Enviar reseña',
                  size: BsmButtonSize.lg,
                  block: true,
                  loading: _enviando,
                  onPressed: _estrellas == 0 ? null : () => _enviar(cita),
                ),
              const SizedBox(height: AppSpace.s2),
              BsmButton(
                label: 'Reservar de nuevo',
                icon: LucideIcons.rotateCcw,
                variant: BsmButtonVariant.ghost,
                block: true,
                onPressed: _enviando ? null : () => iniciarReservaDesdeCita(context, ref, cita, reprogramar: false),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.s6),
          children: [
            header(status),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ServiceTypeBadge(tipo: cita.servicio.nombre),
                      const SizedBox(width: AppSpace.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cita.servicio.nombre, style: AppTextStyles.titleSm.copyWith(color: p.ink)),
                            Text('con $barbero · ${Formato.fechaLarga(inicio)}, ${Formato.hora(inicio)}', style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s6),
                  if (!puedeCalificar)
                    BsmBanner(
                      tone: cita.tieneReview ? BsmBannerTone.success : BsmBannerTone.info,
                      title: cita.tieneReview ? 'Ya calificaste esta cita' : 'Podrás calificarla cuando se complete',
                      body: cita.tieneReview ? 'Gracias por contarnos cómo te fue.' : null,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSpace.s5),
                      decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.line), borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: Column(
                        children: [
                          BsmAvatar(name: barbero, photoUrl: cita.barbero.fotoUrl, size: 64),
                          const SizedBox(height: AppSpace.s3),
                          Semantics(
                            header: true,
                            child: Text('¿Cómo te fue con ${cita.barbero.nombre}?', textAlign: TextAlign.center, style: AppTextStyles.title.copyWith(color: p.ink)),
                          ),
                          const SizedBox(height: AppSpace.s3),
                          Semantics(
                            label: 'Calificación',
                            container: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 1; i <= 5; i++)
                                  Semantics(
                                    inMutuallyExclusiveGroup: true,
                                    checked: _estrellas == i,
                                    button: true,
                                    label: i == 1 ? '1 estrella' : '$i estrellas',
                                    excludeSemantics: true,
                                    child: InkResponse(
                                      onTap: _enviando ? null : () => setState(() => _estrellas = i),
                                      radius: 28,
                                      child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Center(child: BsmStar(color: i <= _estrellas ? p.brassInk : p.lineStrong, filled: i <= _estrellas, size: 32)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpace.s1),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _estrellas == 0 ? 'Toca una estrella' : _etiquetas[_estrellas - 1],
                              style: AppTextStyles.label.copyWith(color: _estrellas == 0 ? p.inkMuted : p.brassInk),
                            ),
                          ),
                          const SizedBox(height: AppSpace.s5),
                          BsmTextField(
                            controller: _comentario,
                            label: 'Cuéntanos más',
                            optional: true,
                            maxLines: 4,
                            placeholder: '¿Qué te gustó? ¿Qué mejorarías?',
                            hint: 'Tu reseña aparecerá en el perfil de ${cita.barbero.nombre}.',
                            validator: (v) => (v?.trim().length ?? 0) > 500 ? 'Escribe máximo 500 caracteres.' : null,
                          ),
                        ],
                      ),
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
