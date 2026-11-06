import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/bsm/bsm.dart';

/// Galería de componentes del sistema (solo en modo debug, ruta `/_componentes`).
/// Datos de ejemplo de design/pantallas; no representan clientes reales.
class ComponentesScreen extends StatefulWidget {
  const ComponentesScreen({super.key});

  @override
  State<ComponentesScreen> createState() => _ComponentesScreenState();
}

class _ComponentesScreenState extends State<ComponentesScreen> {
  String _service = 'Corte + barba';
  String _barber = 'Julián Restrepo';
  String _filter = 'Todos';
  String? _slot = '15:00';
  DateTime _day = DateTime(2026, 11, 12);
  int _nav = 0;
  bool _switch = true;
  String? _select;
  List<String> _specialties = ['Fade', 'Barba', 'Diseños'];
  DateTime _expires = DateTime.now().add(const Duration(minutes: 4, seconds: 32));

  Widget _section(String title, List<Widget> children) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(color: p.line),
          const SizedBox(height: AppSpace.s4),
          Text(title, style: AppTextStyles.titleLg.copyWith(color: p.ink)),
          const SizedBox(height: AppSpace.s4),
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: AppSpace.s3), children[i]],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final today = DateTime(2026, 11, 6);
    return Scaffold(
      appBar: AppBar(title: Text('Componentes', style: AppTextStyles.display.copyWith(color: p.ink, fontSize: 24))),
      bottomNavigationBar: BsmBottomNav(
        items: BsmBottomNav.clientItems,
        selectedIndex: _nav,
        onSelected: (i) => setState(() => _nav = i),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s2, AppSpace.s4, AppSpace.s16),
        children: [
          const Row(children: [BsmLogo(horizontal: true), SizedBox(width: AppSpace.s6), BsmLogo()]),
          _section('Botones', [
            BsmButton(label: 'Reservar ahora', size: BsmButtonSize.lg, block: true, onPressed: () => showBsmToast(context, 'Reserva confirmada')),
            Wrap(spacing: AppSpace.s2, runSpacing: AppSpace.s2, children: [
              BsmButton(label: 'Reprogramar', icon: LucideIcons.calendarClock, variant: BsmButtonVariant.secondary, onPressed: () {}),
              BsmButton(label: 'Calificar servicio', icon: LucideIcons.star, variant: BsmButtonVariant.ghost, onPressed: () {}),
              BsmButton(
                label: 'Cancelar cita',
                variant: BsmButtonVariant.dangerGhost,
                onPressed: () async {
                  final ok = await showBsmConfirm(
                    context,
                    title: '¿Cancelar esta cita?',
                    body: 'Se liberará el horario del jueves 12 de noviembre a las 3:00 p. m. con Julián. Esta acción no se puede deshacer.',
                    confirmLabel: 'Sí, cancelar cita',
                  );
                  if (ok && context.mounted) {
                    showBsmToast(context, 'Cita cancelada', actionLabel: 'Deshacer', onAction: () {});
                  }
                },
              ),
              BsmButton(label: 'Reservando…', loading: true, onPressed: () {}),
              const BsmButton(label: 'Continuar', onPressed: null),
              BsmIconButton(icon: LucideIcons.bell, label: 'Notificaciones', badge: true, onPressed: () {}),
            ]),
          ]),
          _section('Campos', [
            const BsmTextField(label: 'Correo', placeholder: 'andres@correo.co', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress, hint: 'Te enviaremos la confirmación aquí.'),
            const BsmTextField(label: 'Contraseña', revealable: true, initialValue: 'secreto123'),
            const BsmTextField(label: 'Teléfono', keyboardType: TextInputType.phone, initialValue: '300 123', errorText: 'Ingresa un número de 10 dígitos.'),
            BsmSelect<String>(
              label: 'Barbero',
              placeholder: 'Todos los barberos',
              value: _select,
              onChanged: (v) => setState(() => _select = v),
              options: const [BsmOption('julian', 'Julián Restrepo'), BsmOption('laura', 'Laura Henao')],
            ),
            const BsmTextField(label: 'Alguna nota para el barbero', optional: true, maxLines: 3, placeholder: 'Ej.: llego 5 minutos antes'),
            BsmSwitchTile(label: 'Recordatorios', hint: 'Te avisamos antes de tu cita.', value: _switch, onChanged: (v) {
              setState(() => _switch = v);
              showBsmToast(context, v ? 'Recordatorios activados' : 'Recordatorios desactivados');
            }),
          ]),
          _section('Chips y estados', [
            Wrap(spacing: AppSpace.s2, runSpacing: AppSpace.s2, children: [
              for (final c in ['Todos', 'Corte', 'Barba', 'Afeitado'])
                BsmFilterChip(label: c, selected: _filter == c, count: c == 'Todos' ? 12 : null, onSelected: (_) => setState(() => _filter = c)),
            ]),
            Wrap(spacing: AppSpace.s2, runSpacing: AppSpace.s2, children: [
              for (final s in _specialties) BsmInputChip(label: s, onRemove: () => setState(() => _specialties = _specialties.where((x) => x != s).toList())),
            ]),
            Wrap(spacing: AppSpace.s2, runSpacing: AppSpace.s2, children: [for (final s in AppointmentStatus.values) StatusBadge(s)]),
            const Wrap(spacing: AppSpace.s3, runSpacing: AppSpace.s2, crossAxisAlignment: WrapCrossAlignment.center, children: [
              BsmBadge('Popular', tone: BsmTone.oxblood),
              BsmBadge('Notificaciones activas', tone: BsmTone.info, icon: LucideIcons.bell),
              BsmRating(value: 4.8, count: 126),
              BsmRating(value: null),
              BsmAvatar(name: 'Laura Henao', available: true),
            ]),
          ]),
          _section('Reserva', [
            BookingStepper(current: 3, onStep: (n) => showBsmToast(context, 'Volver al paso $n', tone: BsmToastTone.info)),
            for (final s in const [('Corte clásico', 'Corte', 40, 35000, 'Popular'), ('Corte + barba', 'Combo', 60, 50000, null), ('Afeitado con toalla caliente', 'Afeitado', 30, 28000, null)])
              ServiceCard(
                name: s.$1,
                type: s.$2,
                durationMinutes: s.$3,
                price: s.$4,
                tag: s.$5,
                description: 'Tijera y máquina, lavado y peinado.',
                selected: _service == s.$1,
                onTap: () => setState(() => _service = s.$1),
              ),
            BarberCard(
              name: 'Julián Restrepo',
              years: 8,
              rating: 4.9,
              reviews: 212,
              specialties: const ['Fade', 'Barba', 'Clásico'],
              selected: _barber == 'Julián Restrepo',
              onTap: () => setState(() => _barber = 'Julián Restrepo'),
              onProfile: () {},
            ),
            BarberCard(name: 'Laura Henao', years: 5, rating: 4.7, reviews: 98, specialPrice: 45000, selected: _barber == 'Laura Henao', onTap: () => setState(() => _barber = 'Laura Henao')),
            const BarberCard(name: 'Mateo Ríos', years: 1, available: false, unavailableLabel: 'Vuelve el lunes'),
            BsmCalendar(
              month: DateTime(2026, 11),
              today: today,
              selected: _day,
              isDisabled: (d) => d.isBefore(today) || d.weekday == DateTime.sunday,
              fewSlots: const {12, 18},
              anySlots: const {13, 14},
              legend: 'Punto naranja: quedan pocos horarios.',
              onSelect: (d) => setState(() => _day = d),
              onPrevMonth: () {},
              onNextMonth: () {},
            ),
            SlotGrid(
              selected: _slot,
              onSelect: (s) => setState(() {
                _slot = s.key;
                _expires = DateTime.now().add(const Duration(minutes: 5));
              }),
              slots: [
                for (final (i, t) in const [(9, 0), (9, 30), (10, 0), (10, 30), (14, 0), (14, 30), (15, 0), (15, 30), (18, 0)].indexed)
                  SlotItem(hour: t.$1, minute: t.$2, available: i % 4 != 3),
              ],
            ),
            BsmCountdown(expiresAt: _expires, onExpired: () => showBsmToast(context, 'Tu horario se liberó', tone: BsmToastTone.warning)),
            Row(children: [
              BsmButton(label: 'Probar 0:45', size: BsmButtonSize.sm, variant: BsmButtonVariant.secondary, onPressed: () => setState(() => _expires = DateTime.now().add(const Duration(seconds: 45)))),
            ]),
          ]),
          _section('Citas', [
            AppointmentCard(
              service: 'Corte + barba',
              barber: 'Julián Restrepo',
              date: DateTime(2026, 11, 12),
              start: DateTime(2026, 11, 12, 15),
              end: DateTime(2026, 11, 12, 15, 50),
              status: AppointmentStatus.confirmada,
              price: 50000,
              onTap: () {},
            ),
            AppointmentCard(
              service: 'Corte clásico',
              barber: 'Laura Henao',
              date: DateTime(2026, 10, 28),
              start: DateTime(2026, 10, 28, 10, 30),
              end: DateTime(2026, 10, 28, 11, 10),
              status: AppointmentStatus.completada,
              actions: [BsmButton(label: 'Calificar servicio', icon: LucideIcons.star, variant: BsmButtonVariant.ghost, size: BsmButtonSize.sm, onPressed: () {})],
            ),
          ]),
          _section('Avisos, carga y vacío', [
            const BsmBanner(tone: BsmBannerTone.info, icon: LucideIcons.calendarClock, title: 'Estás reprogramando tu cita', body: 'Al confirmar, la anterior se cancela automáticamente.'),
            BsmBanner(tone: BsmBannerTone.danger, title: 'No pudimos cargar los horarios', body: 'Revisa tu conexión e inténtalo de nuevo.', actionLabel: 'Reintentar', onAction: () {}),
            BsmButton(
              label: 'Abrir formulario',
              variant: BsmButtonVariant.secondary,
              onPressed: () => showBsmSheet<void>(
                context,
                title: 'Nuevo servicio',
                child: const BsmTextField(label: 'Nombre'),
                actions: [
                  BsmButton(label: 'Cancelar', variant: BsmButtonVariant.secondary, onPressed: () => Navigator.pop(context)),
                  BsmButton(label: 'Guardar', onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const BsmSkeleton(variant: BsmSkeletonVariant.card, count: 2),
            const BsmSkeleton(variant: BsmSkeletonVariant.slots),
            BsmEmptyState(title: 'Aún no tienes citas', body: 'Cuando reserves, aparecerán aquí.', actionLabel: 'Reservar', actionIcon: LucideIcons.calendarPlus, onAction: () {}),
            BsmEmptyState(isError: true, title: 'No pudimos cargar los barberos', body: 'Revisa tu conexión e inténtalo de nuevo.', actionLabel: 'Reintentar', actionIcon: LucideIcons.refreshCw, onAction: () {}),
          ]),
        ],
      ),
    );
  }
}
