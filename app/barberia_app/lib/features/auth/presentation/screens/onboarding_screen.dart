import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/services/permiso_notificaciones.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bsm/bsm.dart';

/// Onboarding de la primera apertura (3 pantallas, saltable): «Reserva en 4
/// pasos» · «Te guardamos el horario» · «Te avisamos antes de tu cita». Las
/// ilustraciones son componentes reales con datos de ejemplo
/// (design/pantallas/app-movil/Onboarding).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _pagina = 0;
  bool _pidiendo = false;

  static const _textos = [
    ('Reserva en 4 pasos', 'Elige servicio, barbero y horario, y confirma. Sin llamadas ni esperas.'),
    ('Te guardamos el horario', 'Mientras confirmas, nadie más puede tomarlo durante 5 minutos. Si se acaba el tiempo, eliges de nuevo.'),
    ('Te avisamos antes de tu cita', 'Activa las notificaciones para recibir la confirmación y un recordatorio antes de tu turno.'),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _terminar() async {
    final router = GoRouter.of(context);
    final storage = ref.read(secureStorageProvider);
    await storage.marcarOnboardingVisto();
    final token = await storage.getToken();
    router.go(token != null && token.isNotEmpty ? '/dashboard' : '/login');
  }

  Future<void> _activar() async {
    setState(() => _pidiendo = true);
    await ref.read(permisoNotificacionesProvider).pedir();
    if (mounted) await _terminar();
  }

  Future<void> _ahoraNo() async {
    await ref.read(permisoNotificacionesProvider).posponer();
    if (mounted) await _terminar();
  }

  void _siguiente() => _pages.nextPage(duration: AppDuration.slow, curve: AppEasing.standard);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ultima = _pagina == _textos.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.s5, AppSpace.s3, AppSpace.s2, 0),
              child: Row(
                children: [
                  const BsmLogo(height: 40),
                  const Spacer(),
                  if (!ultima) TextButton(onPressed: _terminar, child: const Text('Saltar')),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _pagina = i),
                children: [
                  for (var i = 0; i < _textos.length; i++)
                    ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpace.s5, AppSpace.s6, AppSpace.s5, AppSpace.s4),
                      children: [
                        ExcludeSemantics(child: IgnorePointer(child: _Ilustracion(pagina: i))),
                        const SizedBox(height: AppSpace.s8),
                        Semantics(header: true, child: Text(_textos[i].$1, style: AppTextStyles.display.copyWith(color: p.ink))),
                        const SizedBox(height: AppSpace.s3),
                        Text(_textos[i].$2, style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted)),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.s5, AppSpace.s2, AppSpace.s5, AppSpace.s5),
              child: Column(
                children: [
                  Semantics(
                    label: 'Paso ${_pagina + 1} de ${_textos.length}',
                    excludeSemantics: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _textos.length; i++)
                          AnimatedContainer(
                            duration: AppDuration.base,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _pagina ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(color: i == _pagina ? p.brass : p.line, borderRadius: BorderRadius.circular(4)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.s5),
                  if (!ultima)
                    BsmButton(label: 'Siguiente', size: BsmButtonSize.lg, block: true, onPressed: _siguiente)
                  else ...[
                    BsmButton(
                      label: _pidiendo ? 'Activando…' : 'Activar recordatorios',
                      icon: LucideIcons.bell,
                      size: BsmButtonSize.lg,
                      block: true,
                      loading: _pidiendo,
                      onPressed: _activar,
                    ),
                    const SizedBox(height: AppSpace.s2),
                    BsmButton(label: 'Ahora no', variant: BsmButtonVariant.ghost, size: BsmButtonSize.lg, block: true, onPressed: _pidiendo ? null : _ahoraNo),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ilustracion extends StatelessWidget {
  const _Ilustracion({required this.pagina});

  final int pagina;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    switch (pagina) {
      case 0:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BookingStepper(current: 2),
            SizedBox(height: AppSpace.s4),
            ServiceCard(name: 'Corte + barba', type: 'Combo', description: 'Corte completo y perfilado de barba.', durationMinutes: 50, price: 50000, selected: true),
            SizedBox(height: AppSpace.s3),
            ServiceCard(name: 'Corte clásico', type: 'Corte', description: 'Tijera y máquina, lavado y peinado.', durationMinutes: 30, price: 35000),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('JUEVES 12 DE NOVIEMBRE', style: AppTextStyles.overline.copyWith(color: p.inkMuted)),
            const SizedBox(height: AppSpace.s3),
            SlotGrid(
              selected: '15:00',
              onSelect: (_) {},
              slots: const [
                SlotItem(hour: 14, minute: 0),
                SlotItem(hour: 14, minute: 30, available: false),
                SlotItem(hour: 15, minute: 0),
                SlotItem(hour: 15, minute: 30),
                SlotItem(hour: 16, minute: 0),
                SlotItem(hour: 16, minute: 30, available: false),
              ],
            ),
            const BsmCountdownView(seconds: 272, compact: true),
          ],
        );
      default:
        return const Column(
          children: [
            _Aviso(icon: LucideIcons.circleCheck, texto: 'Julián confirmó tu cita del jueves 12 de noviembre.'),
            SizedBox(height: AppSpace.s3),
            _Aviso(icon: LucideIcons.bell, texto: 'Tu cita es mañana a las 3:00 p. m. con Julián.'),
            SizedBox(height: AppSpace.s3),
            _Aviso(icon: LucideIcons.star, texto: '¿Cómo te fue? Califica tu corte.'),
          ],
        );
    }
  }
}

/// Aviso con el aspecto del toast del sistema (`inverse`), solo ilustrativo.
class _Aviso extends StatelessWidget {
  const _Aviso({required this.icon, required this.texto});

  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: AppSpace.s3),
      decoration: BoxDecoration(color: p.inverse, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: p.onInverse),
          const SizedBox(width: AppSpace.s3),
          Expanded(child: Text(texto, style: AppTextStyles.body.copyWith(color: p.onInverse, fontSize: 15))),
        ],
      ),
    );
  }
}
