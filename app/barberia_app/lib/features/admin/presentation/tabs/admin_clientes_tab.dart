import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../data/admin_repository.dart';
import '../../data/models/admin_cliente_model.dart';
import '../providers/admin_clientes_provider.dart';
import '../widgets/admin_kit.dart';

String _sinTildes(String s) {
  const de = 'áéíóúüñÁÉÍÓÚÜÑ';
  const a = 'aeiouunAEIOUUN';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = de.indexOf(ch);
    b.write(i >= 0 ? a[i] : ch);
  }
  return b.toString().toLowerCase();
}

/// Clientes en la app: búsqueda, estado y edición. Las cuentas del equipo
/// (administradores y barberos) se gestionan en Usuarios del panel web.
class AdminClientesTab extends ConsumerStatefulWidget {
  const AdminClientesTab({super.key});

  @override
  ConsumerState<AdminClientesTab> createState() => _AdminClientesTabState();
}

class _AdminClientesTabState extends ConsumerState<AdminClientesTab> {
  AdminFiltro _filtro = AdminFiltro.todos;
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(adminClientesProvider);
    final p = context.palette;

    return clientesAsync.when(
      loading: () => const AdminLoading(),
      error: (e, _) => AdminError(title: 'No pudimos cargar los clientes', error: e, onRetry: () => ref.invalidate(adminClientesProvider)),
      data: (lista) {
        final todos = lista.where((c) => c.rol.isEmpty || c.rol.toLowerCase() == 'cliente').toList()
          ..sort((a, b) => (a.activo == b.activo) ? a.nombreCompleto.compareTo(b.nombreCompleto) : (a.activo ? -1 : 1));
        final activos = todos.where((c) => c.activo).length;
        final q = _sinTildes(_busqueda.trim());
        final digitos = _busqueda.replaceAll(RegExp(r'\D'), '');
        final items = todos
            .where((c) => adminPasaFiltro(_filtro, c.activo))
            .where((c) => q.isEmpty || _sinTildes('${c.nombreCompleto} ${c.correo}').contains(q) || (digitos.length >= 3 && c.telefono.replaceAll(RegExp(r'\D'), '').contains(digitos)))
            .toList();

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminClientesProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(AppSpace.s4),
            children: [
              AdminHeader(
                title: 'Clientes',
                subtitle: todos.length == 1 ? '1 cliente' : '${todos.length} clientes',
                actionLabel: 'Nuevo',
                actionIcon: LucideIcons.userPlus,
                onAction: () => _abrirFormulario(context),
              ),
              if (todos.isNotEmpty) ...[
                BsmTextField(
                  icon: LucideIcons.search,
                  placeholder: 'Buscar por nombre, correo o celular',
                  keyboardType: TextInputType.text,
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
                const SizedBox(height: AppSpace.s3),
                AdminFiltroChips(value: _filtro, onChanged: (f) => setState(() => _filtro = f), activos: activos, inactivos: todos.length - activos),
              ],
              if (todos.isEmpty)
                BsmEmptyState(
                  icon: LucideIcons.users,
                  title: 'Aún no tienes clientes',
                  body: 'Se registran solos desde la app, o puedes agregar a quien llama o llega sin reserva.',
                  actionLabel: 'Nuevo cliente',
                  actionIcon: LucideIcons.userPlus,
                  onAction: () => _abrirFormulario(context),
                )
              else if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.s8),
                  child: Text(
                    _busqueda.trim().isEmpty ? 'No hay clientes con ese estado.' : 'Nadie coincide con «${_busqueda.trim()}». Revisa la ortografía o busca por celular.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: p.inkMuted),
                  ),
                )
              else
                for (final c in items)
                  AdminRow(
                    inactive: !c.activo,
                    leading: BsmAvatar(name: c.nombreCompleto, size: 40),
                    title: c.nombreCompleto,
                    subtitle: [c.correo, if (c.telefono.isNotEmpty) Formato.telefono(c.telefono)].join(' · '),
                    badges: [adminEstadoBadge(c.activo)],
                    onTap: () => _abrirFormulario(context, cliente: c),
                    trailing: BsmIconButton(
                      icon: c.activo ? LucideIcons.ban : LucideIcons.rotateCcw,
                      label: c.activo ? 'Desactivar a ${c.nombre}' : 'Activar a ${c.nombre}',
                      onPressed: () => _cambiarEstado(context, c),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cambiarEstado(BuildContext context, AdminClienteModel c) async {
    final ok = await showBsmConfirm(
      context,
      title: c.activo ? '¿Desactivar a ${c.nombre}?' : '¿Activar a ${c.nombre}?',
      body: c.activo ? 'No podrá entrar a la app ni reservar. Sus citas ya agendadas se mantienen.' : 'Podrá volver a entrar a la app y reservar.',
      confirmLabel: c.activo ? 'Desactivar cliente' : 'Activar cliente',
      tone: c.activo ? BsmConfirmTone.danger : BsmConfirmTone.info,
      icon: c.activo ? LucideIcons.ban : LucideIcons.rotateCcw,
    );
    if (!ok) return;
    try {
      await ref.read(adminRepositoryProvider).updateCliente(id: c.id, nombre: c.nombre, apellido: c.apellido, telefono: c.telefono, correo: c.correo, activo: !c.activo);
      ref.invalidate(adminClientesProvider);
      if (context.mounted) showBsmToast(context, c.activo ? '${c.nombre} quedó desactivado' : '${c.nombre} quedó activo');
    } catch (e) {
      if (context.mounted) adminToastError(context, e, 'No pudimos cambiar el estado del cliente.');
    }
  }

  Future<void> _abrirFormulario(BuildContext context, {AdminClienteModel? cliente}) async {
    final mensaje = await showBsmSheet<String>(
      context,
      title: cliente == null ? 'Nuevo cliente' : 'Editar datos',
      subtitle: cliente?.nombreCompleto ?? 'Podrá entrar a la app con su correo y esta contraseña.',
      child: _ClienteForm(cliente: cliente),
    );
    if (mensaje == null) return;
    ref.invalidate(adminClientesProvider);
    if (context.mounted) showBsmToast(context, mensaje);
  }
}

class _ClienteForm extends ConsumerStatefulWidget {
  const _ClienteForm({required this.cliente});

  final AdminClienteModel? cliente;

  @override
  ConsumerState<_ClienteForm> createState() => _ClienteFormState();
}

class _ClienteFormState extends ConsumerState<_ClienteForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.cliente?.nombre ?? '');
  late final _apellido = TextEditingController(text: widget.cliente?.apellido ?? '');
  late final _telefono = TextEditingController(text: widget.cliente?.telefono ?? '');
  late final _correo = TextEditingController(text: widget.cliente?.correo ?? '');
  final _password = TextEditingController();
  bool _saving = false;

  bool get _nuevo => widget.cliente == null;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _telefono, _correo, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repo = ref.read(adminRepositoryProvider);
    try {
      if (_nuevo) {
        await repo.createCliente(nombre: _nombre.text.trim(), apellido: _apellido.text.trim(), telefono: _telefono.text.trim(), correo: _correo.text.trim(), password: _password.text);
      } else {
        await repo.updateCliente(
          id: widget.cliente!.id,
          nombre: _nombre.text.trim(),
          apellido: _apellido.text.trim(),
          telefono: _telefono.text.trim(),
          correo: _correo.text.trim(),
          password: _password.text.isEmpty ? null : _password.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(_nuevo ? '${_nombre.text.trim()} quedó registrado' : 'Datos guardados');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      adminToastError(context, e, 'No pudimos guardar el cliente. Inténtalo de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          BsmTextField(controller: _telefono, label: 'Celular', keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, validator: AdminValida.telefono),
          gap,
          BsmTextField(controller: _correo, label: 'Correo', keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.email], validator: AdminValida.correo),
          gap,
          BsmTextField(
            controller: _password,
            label: _nuevo ? 'Contraseña' : 'Nueva contraseña',
            optional: !_nuevo,
            revealable: true,
            hint: _nuevo ? 'Mínimo 6 caracteres. Compártela con el cliente.' : 'Déjala vacía para no cambiarla.',
            validator: (v) {
              final t = v ?? '';
              if (_nuevo && t.length < 6) return 'Usa al menos 6 caracteres.';
              if (!_nuevo && t.isNotEmpty && t.length < 6) return 'Usa al menos 6 caracteres, o déjala vacía.';
              return null;
            },
          ),
          const SizedBox(height: AppSpace.s6),
          BsmButton(
            label: _saving ? 'Guardando…' : (_nuevo ? 'Registrar cliente' : 'Guardar cambios'),
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
