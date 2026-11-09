import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../servicios/domain/servicio_model.dart';
import '../../data/admin_servicio_repository.dart';
import '../providers/admin_servicios_provider.dart';
import '../widgets/admin_kit.dart';

const _tipos = ['Corte', 'Barba', 'Afeitado', 'Tinte', 'Tratamiento', 'Combo', 'Otro'];

/// Catálogo de servicios en la app (mismas reglas que el panel: 10–240 min,
/// precio > $0, desactivar en vez de eliminar).
class AdminServiciosTab extends ConsumerStatefulWidget {
  const AdminServiciosTab({super.key});

  @override
  ConsumerState<AdminServiciosTab> createState() => _AdminServiciosTabState();
}

class _AdminServiciosTabState extends ConsumerState<AdminServiciosTab> {
  AdminFiltro _filtro = AdminFiltro.todos;

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(adminServiciosTabProvider);
    final p = context.palette;

    return dataAsync.when(
      loading: () => const AdminLoading(),
      error: (e, _) => AdminError(title: 'No pudimos cargar los servicios', error: e, onRetry: () => ref.invalidate(adminServiciosTabProvider)),
      data: (data) {
        if (data.barberiaId == null) {
          return const BsmEmptyState(icon: LucideIcons.store, title: 'Aún no hay barbería', body: 'Configura la barbería primero para crear servicios.');
        }
        final todos = [...data.servicios]..sort((a, b) => (a.activo == b.activo) ? a.nombre.compareTo(b.nombre) : (a.activo ? -1 : 1));
        final activos = todos.where((s) => s.activo).length;
        final items = todos.where((s) => adminPasaFiltro(_filtro, s.activo)).toList();

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminServiciosTabProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(AppSpace.s4),
            children: [
              AdminHeader(
                title: 'Servicios',
                subtitle: activos == 1 ? '1 servicio activo en la app' : '$activos servicios activos en la app',
                actionLabel: 'Nuevo',
                onAction: () => _abrirFormulario(context),
              ),
              if (todos.isNotEmpty) AdminFiltroChips(value: _filtro, onChanged: (f) => setState(() => _filtro = f), activos: activos, inactivos: todos.length - activos),
              if (todos.isEmpty)
                BsmEmptyState(
                  icon: LucideIcons.scissors,
                  title: 'Aún no tienes servicios',
                  body: 'Crea el primero para que tus clientes puedan reservar.',
                  actionLabel: 'Nuevo servicio',
                  actionIcon: LucideIcons.plus,
                  onAction: () => _abrirFormulario(context),
                )
              else if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.s8),
                  child: Text('No hay servicios con ese estado.', textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                )
              else
                for (final s in items)
                  AdminRow(
                    inactive: !s.activo,
                    leading: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: p.brassSoft, borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: ServiceTypeIcon(tipo: s.tipo, size: 22),
                    ),
                    title: s.nombre,
                    subtitle: '${s.tipo} · ${Formato.duracion(s.duracionMinutos)} · ${Formato.dinero(s.precio)}',
                    badges: [adminEstadoBadge(s.activo)],
                    onTap: () => _abrirFormulario(context, servicio: s),
                    trailing: BsmIconButton(
                      icon: s.activo ? LucideIcons.ban : LucideIcons.rotateCcw,
                      label: s.activo ? 'Desactivar ${s.nombre}' : 'Activar ${s.nombre}',
                      onPressed: () => _cambiarEstado(context, s),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cambiarEstado(BuildContext context, ServicioModel s) async {
    final ok = await showBsmConfirm(
      context,
      title: s.activo ? '¿Desactivar «${s.nombre}»?' : '¿Activar «${s.nombre}»?',
      body: s.activo
          ? 'Deja de aparecer en la app. Las citas ya agendadas se mantienen y puedes activarlo cuando quieras.'
          : 'Volverá a aparecer en la app para los barberos que lo prestan.',
      confirmLabel: s.activo ? 'Desactivar servicio' : 'Activar servicio',
      tone: s.activo ? BsmConfirmTone.danger : BsmConfirmTone.info,
      icon: s.activo ? LucideIcons.ban : LucideIcons.rotateCcw,
    );
    if (!ok) return;
    final repo = ref.read(adminServicioRepositoryProvider);
    try {
      if (s.activo) {
        await repo.deleteServicio(s.id);
      } else {
        await repo.activarServicio(s.id);
      }
      ref.invalidate(adminServiciosTabProvider);
      if (context.mounted) showBsmToast(context, s.activo ? 'Servicio desactivado' : 'Servicio activado');
    } catch (e) {
      if (context.mounted) adminToastError(context, e, 'No pudimos cambiar el estado del servicio.');
    }
  }

  Future<void> _abrirFormulario(BuildContext context, {ServicioModel? servicio}) async {
    final mensaje = await showBsmSheet<String>(
      context,
      title: servicio == null ? 'Nuevo servicio' : 'Editar servicio',
      subtitle: servicio == null ? 'Aparece en el paso 1 de la reserva.' : servicio.nombre,
      child: _ServicioForm(servicio: servicio),
    );
    if (mensaje == null) return;
    ref.invalidate(adminServiciosTabProvider);
    if (context.mounted) showBsmToast(context, mensaje);
  }
}

class _ServicioForm extends ConsumerStatefulWidget {
  const _ServicioForm({required this.servicio});

  final ServicioModel? servicio;

  @override
  ConsumerState<_ServicioForm> createState() => _ServicioFormState();
}

class _ServicioFormState extends ConsumerState<_ServicioForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.servicio?.nombre ?? '');
  late final _descripcion = TextEditingController(text: widget.servicio?.descripcion ?? '');
  late final _duracion = TextEditingController(text: '${widget.servicio?.duracionMinutos ?? 30}');
  late final _precio = TextEditingController(text: widget.servicio == null ? '' : widget.servicio!.precio.toStringAsFixed(0));
  late final _foto = TextEditingController(text: widget.servicio?.fotoUrl ?? '');
  late String _tipo = _tipos.contains(widget.servicio?.tipo) ? widget.servicio!.tipo : (widget.servicio == null ? 'Corte' : 'Otro');
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_nombre, _descripcion, _duracion, _precio]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_nombre, _descripcion, _duracion, _precio, _foto]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repo = ref.read(adminServicioRepositoryProvider);
    final foto = _foto.text.trim();
    try {
      if (widget.servicio == null) {
        await repo.createServicio(
          nombre: _nombre.text.trim(),
          descripcion: _descripcion.text.trim(),
          tipo: _tipo,
          duracionMinutos: int.parse(_duracion.text.trim()),
          precio: double.parse(_precio.text.trim()),
          fotoUrl: foto.isEmpty ? null : foto,
        );
      } else {
        await repo.updateServicio(
          id: widget.servicio!.id,
          nombre: _nombre.text.trim(),
          descripcion: _descripcion.text.trim(),
          tipo: _tipo,
          duracionMinutos: int.parse(_duracion.text.trim()),
          precio: double.parse(_precio.text.trim()),
          fotoUrl: foto.isEmpty ? null : foto,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(widget.servicio == null ? 'Servicio creado' : 'Cambios guardados');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      adminToastError(context, e, 'No pudimos guardar el servicio. Inténtalo de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final duracion = int.tryParse(_duracion.text.trim()) ?? 30;
    final precio = double.tryParse(_precio.text.trim()) ?? 0;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BsmTextField(controller: _nombre, label: 'Nombre', textInputAction: TextInputAction.next, validator: (v) => AdminValida.requerido(v, 'Escribe el nombre del servicio.')),
          const SizedBox(height: AppSpace.s4),
          BsmTextField(controller: _descripcion, label: 'Descripción', optional: true, maxLines: 3, hint: 'Una o dos frases. Se ve en la tarjeta del servicio.'),
          const SizedBox(height: AppSpace.s4),
          BsmSelect<String>(
            label: 'Tipo',
            value: _tipo,
            options: [for (final t in _tipos) BsmOption(t, t)],
            onChanged: (v) => setState(() => _tipo = v ?? _tipo),
          ),
          const SizedBox(height: AppSpace.s4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BsmTextField(
                  controller: _duracion,
                  label: 'Duración (min)',
                  hint: 'Entre 10 y 240.',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final d = int.tryParse((v ?? '').trim());
                    if (d == null || d < 10 || d > 240) return 'Entre 10 y 240 minutos.';
                    if (d % 5 != 0) return 'Usa pasos de 5 minutos.';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: BsmTextField(
                  controller: _precio,
                  label: 'Precio',
                  placeholder: '45000',
                  hint: 'En pesos, sin puntos.',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => (double.tryParse((v ?? '').trim()) ?? 0) > 0 ? null : 'Ingresa un precio mayor a \$0.',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s4),
          BsmTextField(controller: _foto, label: 'Foto', optional: true, icon: LucideIcons.imagePlus, placeholder: 'https://…', hint: 'Sin foto se usa el ícono del tipo de servicio.', keyboardType: TextInputType.url, validator: AdminValida.url),
          const SizedBox(height: AppSpace.s5),
          Text('ASÍ SE VE EN LA APP', style: AppTextStyles.overline.copyWith(color: p.inkMuted)),
          const SizedBox(height: AppSpace.s2),
          ServiceCard(
            name: _nombre.text.trim().isEmpty ? 'Nombre del servicio' : _nombre.text.trim(),
            type: _tipo,
            description: _descripcion.text.trim().isEmpty ? null : _descripcion.text.trim(),
            durationMinutes: duracion,
            price: precio,
          ),
          const SizedBox(height: AppSpace.s6),
          BsmButton(
            label: _saving ? 'Guardando…' : (widget.servicio == null ? 'Crear servicio' : 'Guardar cambios'),
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
