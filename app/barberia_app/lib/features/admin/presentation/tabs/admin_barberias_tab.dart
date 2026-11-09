import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/auth/auth_role_provider.dart';
import '../../../../core/auth/jwt_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../data/admin_repository.dart';
import '../../data/models/admin_barberia_model.dart';
import '../../data/admin_barberia_repository_helper.dart';
import '../providers/admin_barberias_provider.dart';
import '../widgets/admin_kit.dart';

/// Nombres del enum `DiaSemana` del backend, de lunes a domingo.
const _dias = [
  ('Lunes', 'Lun'),
  ('Martes', 'Mar'),
  ('Miercoles', 'Mié'),
  ('Jueves', 'Jue'),
  ('Viernes', 'Vie'),
  ('Sabado', 'Sáb'),
  ('Domingo', 'Dom'),
];

final _horas = [
  for (var m = 5 * 60; m <= 23 * 60; m += 30) '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}',
];

String _hhmm(String v) => v.length >= 5 ? v.substring(0, 5) : v;
int _min(String hhmm) => int.parse(hhmm.substring(0, 2)) * 60 + int.parse(hhmm.substring(3, 5));
String _hora(String hhmm) => Formato.horaDe(int.parse(hhmm.substring(0, 2)), int.parse(hhmm.substring(3, 5)));

/// «Mi negocio» (design/pantallas/panel-web/Mi-negocio): la configuración de la
/// barbería elegida, sin crear ni eliminar (eso es del panel del SuperAdmin).
class AdminBarberiasTab extends ConsumerWidget {
  const AdminBarberiasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminBarberiasProvider);
    final elegidaId = ref.watch(adminBarberiaIdProvider).valueOrNull;
    return async.when(
      loading: () => const AdminLoading(),
      error: (e, _) => AdminError(title: 'No pudimos cargar tu barbería', error: e, onRetry: () => ref.invalidate(adminBarberiasProvider)),
      data: (lista) {
        final barberia = lista.where((b) => b.id == elegidaId).firstOrNull;
        return barberia == null
            ? const BsmEmptyState(icon: LucideIcons.store, title: 'No encontramos tu barbería', body: 'Cierra sesión y elige tu barbería de nuevo.')
            : _NegocioForm(key: ValueKey(barberia.id), barberia: barberia);
      },
    );
  }
}

class _NegocioForm extends ConsumerStatefulWidget {
  const _NegocioForm({super.key, required this.barberia});

  final AdminBarberiaModel barberia;

  @override
  ConsumerState<_NegocioForm> createState() => _NegocioFormState();
}

class _NegocioFormState extends ConsumerState<_NegocioForm> {
  final _formKey = GlobalKey<FormState>();
  late final AdminBarberiaModel b = widget.barberia;
  late final _nombre = TextEditingController(text: b.nombre);
  late final _slogan = TextEditingController(text: b.slogan);
  late final _descripcion = TextEditingController(text: b.descripcion);
  late final _foto = TextEditingController(text: b.fotoPortada);
  late final _telefono = TextEditingController(text: b.telefono);
  late final _correo = TextEditingController(text: b.correo);
  late final _web = TextEditingController(text: b.sitioWeb);
  late final _direccion = TextEditingController(text: b.direccion);
  late final _ciudad = TextEditingController(text: b.ciudad);
  late final _departamento = TextEditingController(text: b.departamento);
  late final _lat = TextEditingController(text: b.latitud == 0 ? '' : '${b.latitud}');
  late final _lng = TextEditingController(text: b.longitud == 0 ? '' : '${b.longitud}');
  late String _abre = _horas.contains(_hhmm(b.horaApertura)) ? _hhmm(b.horaApertura) : '09:00';
  late String _cierra = _horas.contains(_hhmm(b.horaCierre)) ? _hhmm(b.horaCierre) : '20:00';
  late final Set<String> _descanso = {...b.diasDescanso};
  late bool _activa = b.activa;
  String? _errorHorario;
  bool _saving = false;

  List<TextEditingController> get _controllers => [_nombre, _slogan, _descripcion, _foto, _telefono, _correo, _web, _direccion, _ciudad, _departamento, _lat, _lng];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  double? _coord(String v) => double.tryParse(v.trim().replaceAll(',', '.'));

  Future<void> _guardar() async {
    final valido = _formKey.currentState?.validate() ?? false;
    setState(() {
      _errorHorario = _min(_abre) >= _min(_cierra)
          ? 'El cierre debe ser después de la apertura.'
          : (_descanso.length == 7 ? 'Deja al menos un día abierto.' : null);
    });
    if (!valido || _errorHorario != null) {
      showBsmToast(context, 'Revisa los campos marcados antes de guardar.', tone: BsmToastTone.warning);
      return;
    }
    if (!_activa && b.activa) {
      final ok = await showBsmConfirm(
        context,
        title: '¿Ocultar la barbería en la app?',
        body: 'Las citas ya agendadas se mantienen, pero nadie podrá reservar hasta que la actives de nuevo.',
        confirmLabel: 'Sí, ocultar barbería',
        icon: LucideIcons.eyeOff,
      );
      if (!ok || !mounted) return;
    }
    setState(() => _saving = true);
    final payload = {
      ...b.toUpsertJson(),
      'nombre': _nombre.text.trim(),
      'slogan': _slogan.text.trim(),
      'descripcion': _descripcion.text.trim(),
      'fotoPortada': _foto.text.trim(),
      'telefono': _telefono.text.trim(),
      'correo': _correo.text.trim(),
      'sitioWeb': _web.text.trim(),
      'direccion': _direccion.text.trim(),
      'ciudad': _ciudad.text.trim(),
      'departamento': _departamento.text.trim(),
      'latitud': _coord(_lat.text) ?? 0,
      'longitud': _coord(_lng.text) ?? 0,
      'horaApertura': '$_abre:00',
      'horaCierre': '$_cierra:00',
      'diasDescanso': [for (final d in _dias) if (_descanso.contains(d.$1)) d.$1],
      'activa': _activa,
    };
    try {
      await ref.read(adminRepositoryProvider).updateBarberia(b.id, payload);
      if (!mounted) return;
      setState(() => _saving = false);
      showBsmToast(context, 'Cambios guardados. Tus clientes ya los ven en la app.');
      ref.invalidate(adminBarberiasProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      adminToastError(context, e, 'No pudimos guardar los cambios. Inténtalo de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const gap = SizedBox(height: AppSpace.s4);
    final opcionesHora = [for (final h in _horas) BsmOption(h, _hora(h))];

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpace.s4),
        children: [
          const AdminHeader(title: 'Tu barbería', subtitle: 'Datos visibles para tus clientes en la app.'),
          _Seccion(
            titulo: 'Identidad',
            ayuda: 'Lo primero que ven tus clientes en Inicio.',
            children: [
              BsmTextField(controller: _nombre, label: 'Nombre', validator: (v) => AdminValida.requerido(v, 'Escribe el nombre de la barbería.')),
              gap,
              BsmTextField(controller: _slogan, label: 'Slogan', optional: true, hint: 'Una frase corta bajo el nombre.'),
              gap,
              BsmTextField(controller: _descripcion, label: 'Descripción', optional: true, maxLines: 3),
              gap,
              BsmTextField(controller: _foto, label: 'Foto de portada', optional: true, icon: LucideIcons.imagePlus, placeholder: 'https://…', hint: 'Una foto horizontal del local.', keyboardType: TextInputType.url, validator: AdminValida.url),
            ],
          ),
          _Seccion(
            titulo: 'Contacto',
            ayuda: 'Alimenta los botones «Llamar» y «WhatsApp» de la app.',
            children: [
              BsmTextField(controller: _telefono, label: 'Teléfono / WhatsApp', keyboardType: TextInputType.phone, validator: AdminValida.telefono),
              gap,
              BsmTextField(controller: _correo, label: 'Correo', keyboardType: TextInputType.emailAddress, validator: AdminValida.correo),
              gap,
              BsmTextField(controller: _web, label: 'Sitio web', optional: true, placeholder: 'https://…', keyboardType: TextInputType.url, validator: AdminValida.url),
            ],
          ),
          _Seccion(
            titulo: 'Ubicación',
            ayuda: 'Las coordenadas definen a dónde lleva «Cómo llegar».',
            children: [
              BsmTextField(controller: _direccion, label: 'Dirección', placeholder: 'Cra. 37 #8A-32', validator: (v) => AdminValida.requerido(v, 'Escribe la dirección del local.')),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: BsmTextField(controller: _ciudad, label: 'Ciudad', validator: (v) => AdminValida.requerido(v, 'Escribe la ciudad.'))),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(child: BsmTextField(controller: _departamento, label: 'Departamento')),
                ],
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BsmTextField(
                      controller: _lat,
                      label: 'Latitud',
                      placeholder: '6.2087',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) {
                        final n = _coord(v ?? '');
                        return (n == null || n == 0 || n.abs() > 90) ? 'Entre -90 y 90.' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: BsmTextField(
                      controller: _lng,
                      label: 'Longitud',
                      placeholder: '-75.5676',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) {
                        final n = _coord(v ?? '');
                        return (n == null || n == 0 || n.abs() > 180) ? 'Entre -180 y 180.' : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s2),
              Text('En Google Maps, mantén presionada la entrada del local y copia las coordenadas.', style: AppTextStyles.caption.copyWith(color: p.inkMuted)),
            ],
          ),
          _Seccion(
            titulo: 'Horario de atención',
            ayuda: 'El horario de cada barbero se ajusta en el panel web.',
            children: [
              Row(
                children: [
                  Expanded(child: BsmSelect<String>(label: 'Abre', value: _abre, options: opcionesHora, onChanged: (v) => setState(() => _abre = v ?? _abre))),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(child: BsmSelect<String>(label: 'Cierra', value: _cierra, options: opcionesHora, onChanged: (v) => setState(() => _cierra = v ?? _cierra))),
                ],
              ),
              gap,
              Text('Días de descanso', style: AppTextStyles.labelSm.copyWith(color: p.ink)),
              const SizedBox(height: AppSpace.s2),
              Wrap(
                spacing: AppSpace.s2,
                runSpacing: AppSpace.s2,
                children: [
                  for (final d in _dias)
                    BsmFilterChip(
                      label: d.$2,
                      selected: _descanso.contains(d.$1),
                      onSelected: (on) => setState(() => on ? _descanso.add(d.$1) : _descanso.remove(d.$1)),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.s2),
              Text(
                _errorHorario ?? 'Marcados: la barbería no abre y la app no muestra horarios ese día.',
                style: AppTextStyles.caption.copyWith(color: _errorHorario != null ? p.danger : p.inkMuted),
              ),
            ],
          ),
          // Activar o desactivar la barbería es del SuperAdmin; el API lo ignora para los demás.
          if (JwtUtils.isAdminRole(ref.watch(authRoleProvider).valueOrNull))
            _Seccion(
              titulo: 'Estado',
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _activa,
                  onChanged: (v) => setState(() => _activa = v),
                  title: Text('Barbería activa', style: AppTextStyles.label.copyWith(color: p.ink)),
                  subtitle: Text(_activa ? 'Visible en la app y recibiendo reservas.' : 'Oculta en la app: nadie puede reservar.', style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                ),
              ],
            ),
          const SizedBox(height: AppSpace.s2),
          BsmButton(label: _saving ? 'Guardando…' : 'Guardar cambios', icon: LucideIcons.check, block: true, size: BsmButtonSize.lg, loading: _saving, onPressed: _saving ? null : _guardar),
          const SizedBox(height: AppSpace.s6),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, this.ayuda, required this.children});

  final String titulo;
  final String? ayuda;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s4),
      child: BsmCardFrame(
        padding: const EdgeInsets.all(AppSpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(titulo, style: AppTextStyles.titleSm.copyWith(color: p.ink)),
            if (ayuda != null) ...[
              const SizedBox(height: AppSpace.s1),
              Text(ayuda!, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
            ],
            const SizedBox(height: AppSpace.s4),
            ...children,
          ],
        ),
      ),
    );
  }
}
