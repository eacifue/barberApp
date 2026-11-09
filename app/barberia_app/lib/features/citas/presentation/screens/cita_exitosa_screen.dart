import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../domain/models/cita_model.dart';
import '../widgets/booking_scaffold.dart';

/// Reserva confirmada: la única celebración del sistema (check en latón, una
/// vez, sin bucle) y los siguientes pasos (design/pantallas/app-movil/Reserva-Exito).
class CitaExitosaScreen extends ConsumerWidget {
  const CitaExitosaScreen({super.key, required this.cita});

  final CitaModel cita;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final barbershop = ref.watch(myBarbershopProvider).valueOrNull;
    final inicio = fechaConHora(cita.fechaCita, cita.horaInicio);
    final fin = fechaConHora(cita.fechaCita, cita.horaFin);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/dashboard');
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.s6, AppSpace.s12, AppSpace.s6, AppSpace.s6),
            children: [
              Center(
                child: ExcludeSemantics(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: AppEasing.enter,
                    builder: (context, t, child) => Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Transform.scale(scale: reduceMotion ? 1 : 0.6 + 0.4 * t, child: child),
                    ),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: p.brassSoft),
                      alignment: Alignment.center,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: p.brass),
                        child: Icon(LucideIcons.check, size: 40, color: p.onBrass),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.s6),
              Semantics(
                header: true,
                liveRegion: true,
                child: Text('Reserva confirmada', textAlign: TextAlign.center, style: AppTextStyles.displayLg.copyWith(color: p.ink)),
              ),
              const SizedBox(height: AppSpace.s2),
              Text(
                'Te enviaremos un recordatorio antes de tu cita.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted),
              ),
              const SizedBox(height: AppSpace.s8),
              Container(
                padding: const EdgeInsets.all(AppSpace.s4),
                decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.line), borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      padding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
                      decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Column(
                        children: [
                          Text(Formato.diaSemana(inicio).substring(0, 3).toUpperCase(), style: AppTextStyles.overline.copyWith(color: p.inkMuted)),
                          Text('${inicio.day}', style: AppTextStyles.display.copyWith(fontSize: 28, height: 32 / 28, color: p.ink)),
                          Text(Formato.fechaCorta(inicio).split(' ').last.toUpperCase(), style: AppTextStyles.overline.copyWith(color: p.inkMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cita.servicio.nombre, style: AppTextStyles.titleSm.copyWith(color: p.ink)),
                          Text('con ${cita.barbero.nombre} ${cita.barbero.apellido}'.trim(), style: AppTextStyles.body.copyWith(color: p.ink)),
                          const SizedBox(height: AppSpace.s1),
                          Text('${Formato.rango(inicio, fin)} · ${Formato.dinero(cita.precioFinal)}', style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                          Text(
                            barbershop == null ? 'Pago en el local' : '${barbershop.direccionCompleta} · Pago en el local',
                            style: AppTextStyles.body.copyWith(color: p.inkMuted),
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
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s2, AppSpace.s4, AppSpace.s4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BsmButton(label: 'Ver mis citas', size: BsmButtonSize.lg, block: true, onPressed: () => context.go('/appointments')),
                const SizedBox(height: AppSpace.s2),
                BsmButton(
                  label: 'Volver al inicio',
                  variant: BsmButtonVariant.secondary,
                  size: BsmButtonSize.lg,
                  block: true,
                  onPressed: () => context.go('/dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
