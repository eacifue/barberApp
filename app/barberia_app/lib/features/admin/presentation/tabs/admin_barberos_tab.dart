import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberos/domain/barbero_model.dart';
import '../../../servicios/domain/servicio_model.dart';
import '../../data/admin_barbero_repository.dart';
import '../providers/admin_barberos_provider.dart';
import '../widgets/admin_kit.dart';

/// Equipo en la app. El horario semanal y los días libres se editan en el
/// panel web (design/pantallas/panel-web/Barberos), que tiene el espacio.
class AdminBarberosTab extends ConsumerStatefulWidget {
  const AdminBarberosTab({super.key});

  @override
  ConsumerState<AdminBarberosTab> createState() => _AdminBarberosTabState();
}

class _AdminBarberosTabState extends ConsumerState<AdminBarberosTab> {
  AdminFiltro _filtro = AdminFiltro.todos;

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(adminBarberosTabProvider);
    final p = context.palette;

    return dataAsync.when(
      loading: () => const AdminLoading(),
      error: (e, _) => AdminError(title: 'No pudimos cargar el equipo', error: e, onRetry: () => ref.invalidate(adminBarberosTabProvider)),
      data: (data) {
        if (data.barberiaId == null) {
          return const BsmEmptyState(icon: LucideIcons.store, title: 'Aún no hay barbería', body: 'Configura la barbería primero para agregar barberos.');
        }
        final servicios = data.servicios.where((s) => s.activo).toList();
        final todos = [...data.barberos]..sort((a, b) => (a.activo == b.activo) ? a.nombreCompleto.compareTo(b.nombreCompleto) : (a.activo ? -1 : 1));
        final activos = todos.where((b) => b.activo).length;
        final items = todos.where((b) => adminPasaFiltro(_filtro, b.activo)).toList();

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminBarberosTabProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(AppSpace.s4),
            children: [
              AdminHeader(
                title: 'Equipo',
                subtitle: activos == 1 ? '1 barbero activo' : '$activos barberos activos',
                actionLabel: servicios.isEmpty ? null : 'Nuevo',
                onAction: () => _abrirFormulario(context, servicios: servicios),
              ),
              if (servicios.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpace.s4),
                  child: BsmBanner(tone: BsmBannerTone.warning, title: 'Primero crea un servicio', body: 'Cada barbero necesita al menos un servicio activo para aparecer en la app.'),
                ),
              if (todos.isNotEmpty) AdminFiltroChips(value: _filtro, onChanged: (f) => setState(() => _filtro = f), activos: activos, inactivos: todos.length - activos),
              if (todos.isEmpty)
                const BsmEmptyState(icon: LucideIcons.scissors, title: 'Aún no tienes barberos', body: 'Agrega el primero con sus servicios para que los clientes puedan reservar.')
              else if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.s8),
                  child: Text('Nadie con ese estado.', textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                )
              else
                for (final b in items)
                  AdminRow(
                    inactive: !b.activo,
                    leading: BsmAvatar(name: b.nombreCompleto, photoUrl: b.fotoUrl, size: 44, available: b.activo ? b.disponible : null),
                    title: b.nombreCompleto,
                    subtitle: [
                      if (b.ratingPromedio > 0) '★ ${Formato.decimal(b.ratingPromedio)}' else 'Nuevo',
                      b.aniosExperiencia == 1 ? '1 año' : '${b.aniosExperiencia} años',
                      b.servicios.length == 1 ? '1 servicio' : '${b.servicios.length} servicios',
                    ].join(' · '),
                    badges: [
                      adminEstadoBadge(b.activo),
                      for (final t in b.especialidades.take(2)) BsmTag(t),
                    ],
                    onTap: b.activo ? () => _abrirFormulario(context, servicios: servicios, barbero: b) : null,
                    trailing: BsmIconButton(
                      icon: b.activo ? LucideIcons.ban : LucideIcons.rotateCcw,
                      label: b.activo ? 'Desactivar a ${b.nombre}' : 'Activar a ${b.nombre}',
                      onPressed: () => _cambiarEstado(context, b, servicios),
                    ),
                  ),
              const SizedBox(height: AppSpace.s2),
              Text('El horario semanal y los días libres se ajustan en el panel web.', textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: p.inkMuted)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cambiarEstado(BuildContext context, BarberoModel b, List<ServicioModel> servicios) async {
    final ok = await showBsmConfirm(
      context,
      title: b.activo ? '¿Desactivar a ${b.nombre}?' : '¿Activar a ${b.nombre}?',
      body: b.activo
          ? 'Deja de aparecer en la app y no recibe nuevas reservas. Sus citas ya agendadas se mantienen. Al activarlo tendrás que confirmar sus servicios.'
          : 'Volverá a aparecer en la app. Después confirma los servicios que presta.',
      confirmLabel: b.activo ? 'Desactivar barbero' : 'Activar barbero',
      tone: b.activo ? BsmConfirmTone.danger : BsmConfirmTone.info,
      icon: b.activo ? LucideIcons.ban : LucideIcons.rotateCcw,
    );
    if (!ok) return;
    final repo = ref.read(adminBarberoRepositoryProvider);
    try {
      if (b.activo) {
        await repo.deleteBarbero(b.id);
        ref.invalidate(adminBarberosTabProvider);
        if (context.mounted) showBsmToast(context, '${b.nombre} quedó desactivado');
      } else {
        final activo = await repo.activarBarbero(b.id);
        ref.invalidate(adminBarberosTabProvider);
        if (!context.mounted) return;
        showBsmToast(context, 'Barbero activado. Confirma los servicios que presta.', tone: BsmToastTone.info);
        await _abrirFormulario(context, servicios: servicios, barbero: activo);
      }
    } catch (e) {
      if (context.mounted) adminToastError(context, e, 'No pudimos cambiar el estado del barbero.');
    }
  }

  Future<void> _abrirFormulario(BuildContext context, {required List<ServicioModel> servicios, BarberoModel? barbero}) async {
    final mensaje = await showBsmSheet<String>(
      context,
      title: barbero == null ? 'Nuevo barbero' : 'Editar barbero',
      subtitle: barbero?.nombreCompleto ?? 'Aparece en la app cuando tenga al menos un servicio.',
      child: _BarberoForm(barbero: barbero, servicios: servicios),
    );
    if (mensaje == null) return;
    ref.invalidate(adminBarberosTabProvider);
    if (context.mounted) showBsmToast(context, mensaje);
  }
}

class _BarberoForm extends ConsumerStatefulWidget {
  const _BarberoForm({required this.barbero, required this.servicios});

  final BarberoModel? barbero;
  final List<ServicioModel> servicios;

  @override
  ConsumerState<_BarberoForm> createState() => _BarberoFormState();
}

class _BarberoFormState extends ConsumerState<_BarberoForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.barbero?.nombre ?? '');
  late final _apellido = TextEditingController(text: widget.barbero?.apellido ?? '');
  late final _telefono = TextEditingController(text: widget.barbero?.telefono ?? '');
  late final _correo = TextEditingController(text: widget.barbero?.correo ?? '');
  late final _bio = TextEditingController(text: widget.barbero?.biografia ?? '');
  late final _anios = TextEditingController(text: widget.barbero == null ? '' : '${widget.barbero!.aniosExperiencia}');
  late final _foto = TextEditingController(text: widget.barbero?.fotoUrl ?? '');
  final _especialidad = TextEditingController();
  late final List<String> _especialidades = [...?widget.barbero?.especialidades];
  late final Set<String> _servicioIds = {for (final s in widget.barbero?.servicios ?? const <ServicioModel>[]) s.id};
  String? _errorServicios;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _telefono, _correo, _bio, _anios, _foto, _especialidad]) {
      c.dispose();
    }
    super.dispose();
  }

  void _agregarEspecialidad() {
    final t = _especialidad.text.trim();
    if (t.isEmpty) return;
    setState(() {
      if (!_especialidades.any((x) => x.toLowerCase() == t.toLowerCase())) _especialidades.add(t);
      _especialidad.clear();
    });
  }

  Future<void> _guardar() async {
    final valido = _formKey.currentState?.validate() ?? false;
    setState(() => _errorServicios = _servicioIds.isEmpty ? 'Elige al menos un servicio.' : null);
    if (!valido || _servicioIds.isEmpty) return;
    setState(() => _saving = true);
    final repo = ref.read(adminBarberoRepositoryProvider);
    final foto = _foto.text.trim();
    final anios = int.tryParse(_anios.text.trim()) ?? 0;
    try {
      if (widget.barbero == null) {
        await repo.createBarbero(
          nombre: _nombre.text.trim(),
          apellido: _apellido.text.trim(),
          telefono: _telefono.text.trim(),
          correo: _correo.text.trim(),
          biografia: _bio.text.trim(),
          aniosExperiencia: anios,
          especialidades: _especialidades,
          servicioIds: _servicioIds.toList(),
          fotoUrl: foto.isEmpty ? null : foto,
        );
      } else {
        await repo.updateBarbero(
          id: widget.barbero!.id,
          nombre: _nombre.text.trim(),
          apellido: _apellido.text.trim(),
          telefono: _telefono.text.trim(),
          correo: _correo.text.trim(),
          biografia: _bio.text.trim(),
          aniosExperiencia: anios,
          especialidades: _especialidades,
          servicioIds: _servicioIds.toList(),
          fotoUrl: foto.isEmpty ? null : foto,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(widget.barbero == null ? '${_nombre.text.trim()} ya está en el equipo' : 'Cambios guardados');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      adminToastError(context, e, 'No pudimos guardar el barbero. Inténtalo de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const gap = SizedBox(height: AppSpace.s4);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: BsmTextField(controller: _nombre, label: 'Nombre', textInputAction: TextInputAction.next, validator: (v) => AdminValida.requerido(v, 'Escribe el nombre.'))),
              const SizedBox(width: AppSpace.s3),
              Expanded(child: BsmTextField(controller: _apellido, label: 'Apellido', textInputAction: TextInputAction.next, validator: (v) => AdminValida.requerido(v, 'Escribe el apellido.'))),
            ],
          ),
          gap,
          BsmTextField(controller: _telefono, label: 'Teléfono', keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, validator: AdminValida.telefono),
          gap,
          BsmTextField(controller: _correo, label: 'Correo', keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, validator: AdminValida.correo),
          gap,
          BsmTextField(
            controller: _anios,
            label: 'Años de experiencia',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => (int.tryParse((v ?? '').trim()) ?? 0) > 60 ? 'Ingresa un número entre 0 y 60.' : null,
          ),
          gap,
          BsmTextField(controller: _bio, label: 'Biografía', optional: true, maxLines: 3, hint: 'Dos o tres frases. Se ve en el perfil del barbero.'),
          gap,
          BsmTextField(controller: _foto, label: 'Foto', optional: true, icon: LucideIcons.imagePlus, placeholder: 'https://…', keyboardType: TextInputType.url, validator: AdminValida.url),
          const SizedBox(height: AppSpace.s5),
          Text('ESPECIALIDADES', style: AppTextStyles.overline.copyWith(color: p.inkMuted)),
          const SizedBox(height: AppSpace.s2),
          if (_especialidades.isNotEmpty) ...[
            Wrap(
              spacing: AppSpace.s2,
              runSpacing: AppSpace.s2,
              children: [for (final t in _especialidades) BsmInputChip(label: t, onRemove: () => setState(() => _especialidades.remove(t)))],
            ),
            const SizedBox(height: AppSpace.s3),
          ],
          BsmTextField(
            controller: _especialidad,
            placeholder: 'Fade, barba clásica…',
            hint: 'En la app se muestran las tres primeras.',
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _agregarEspecialidad(),
            trailing: BsmIconButton(icon: LucideIcons.plus, label: 'Agregar especialidad', onPressed: _agregarEspecialidad),
          ),
          const SizedBox(height: AppSpace.s5),
          Text('SERVICIOS QUE PRESTA', style: AppTextStyles.overline.copyWith(color: p.inkMuted)),
          const SizedBox(height: AppSpace.s1),
          Text(
            _errorServicios ?? (widget.barbero != null && _servicioIds.isEmpty ? 'Confirma los servicios que presta. Al menos uno.' : 'Al menos uno. Se cobra el precio general.'),
            style: AppTextStyles.caption.copyWith(color: _errorServicios != null ? p.danger : p.inkMuted),
          ),
          const SizedBox(height: AppSpace.s2),
          Wrap(
            spacing: AppSpace.s2,
            runSpacing: AppSpace.s2,
            children: [
              for (final s in widget.servicios)
                BsmFilterChip(
                  label: '${s.nombre} · ${Formato.duracion(s.duracionMinutos)}',
                  selected: _servicioIds.contains(s.id),
                  onSelected: (on) => setState(() {
                    on ? _servicioIds.add(s.id) : _servicioIds.remove(s.id);
                    if (_servicioIds.isNotEmpty) _errorServicios = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.s6),
          BsmButton(
            label: _saving ? 'Guardando…' : (widget.barbero == null ? 'Crear barbero' : 'Guardar cambios'),
            icon: LucideIcons.check,
            block: true,
            loading: _saving,
            onPressed: _saving ? null : _guardar,
          ),
        ],
      ),
    );
  }
}
