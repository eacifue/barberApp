import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/admin_empty_state.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../data/admin_repository.dart';
import '../../data/models/admin_cliente_model.dart';
import '../providers/admin_clientes_provider.dart';

class AdminClientesTab extends ConsumerWidget {
  const AdminClientesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(adminClientesProvider);

    return clientesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => BarberiaErrorWidget(
        message: error is AppException
            ? error.message
            : 'No pudimos cargar los clientes.',
        onRetry: () => ref.invalidate(adminClientesProvider),
      ),
      data: (items) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminClientesProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _showClienteForm(context, ref),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Nuevo cliente'),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const AdminEmptyState(message: 'No hay clientes registrados.')
              else
                for (final item in items) ...[
                  AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.nombreCompleto),
                      subtitle: Text('${item.correo} · ${item.rol}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          Icon(
                            item.activo
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            color: item.activo
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).colorScheme.error,
                          ),
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () =>
                                _showClienteForm(context, ref, cliente: item),
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          IconButton(
                            tooltip: 'Desactivar',
                            onPressed: item.rol.toLowerCase() == 'admin'
                                ? null
                                : () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Desactivar cliente'),
                                        content: Text(
                                          '¿Desactivar "${item.nombreCompleto}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Desactivar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed != true) {
                                      return;
                                    }

                                    try {
                                      await ref
                                          .read(adminRepositoryProvider)
                                          .deleteCliente(item.id);
                                      ref.invalidate(adminClientesProvider);
                                    } on AppException catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(e.message)),
                                        );
                                      }
                                    } catch (_) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'No pudimos desactivar el cliente. Intenta de nuevo.',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.person_off_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showClienteForm(
    BuildContext context,
    WidgetRef ref, {
    AdminClienteModel? cliente,
  }) {
    final isEdit = cliente != null;

    final nombreController = TextEditingController(text: cliente?.nombre ?? '');
    final apellidoController = TextEditingController(
      text: cliente?.apellido ?? '',
    );
    final telefonoController = TextEditingController(
      text: cliente?.telefono ?? '',
    );
    final correoController = TextEditingController(text: cliente?.correo ?? '');
    final passwordController = TextEditingController();
    var activo = cliente?.activo ?? true;

    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        var saving = false;
        var obscurePassword = true;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isEdit ? 'Editar cliente' : 'Nuevo cliente',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: apellidoController,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: telefonoController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: correoController,
                      decoration: const InputDecoration(labelText: 'Correo'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: isEdit
                            ? 'Nueva contraseña (opcional)'
                            : 'Contraseña',
                        suffixIcon: IconButton(
                          tooltip: obscurePassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                          onPressed: () => setSheetState(
                            () => obscurePassword = !obscurePassword,
                          ),
                        ),
                      ),
                      obscureText: obscurePassword,
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (!isEdit && text.isEmpty) return 'Requerido';
                        if (text.isNotEmpty && text.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 4),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Activo'),
                        value: activo,
                        onChanged: cliente.rol.toLowerCase() == 'admin'
                            ? null
                            : (value) => setSheetState(() => activo = value),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }

                                setSheetState(() => saving = true);
                                try {
                                  final repo = ref.read(adminRepositoryProvider);
                                  if (isEdit) {
                                    await repo.updateCliente(
                                      id: cliente.id,
                                      nombre: nombreController.text.trim(),
                                      apellido: apellidoController.text.trim(),
                                      telefono: telefonoController.text.trim(),
                                      correo: correoController.text.trim(),
                                      password:
                                          passwordController.text.trim().isEmpty
                                          ? null
                                          : passwordController.text.trim(),
                                      activo: activo,
                                    );
                                  } else {
                                    await repo.createCliente(
                                      nombre: nombreController.text.trim(),
                                      apellido: apellidoController.text.trim(),
                                      telefono: telefonoController.text.trim(),
                                      correo: correoController.text.trim(),
                                      password: passwordController.text.trim(),
                                    );
                                  }

                                  ref.invalidate(adminClientesProvider);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                } on AppException catch (e) {
                                  setSheetState(() => saving = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.message)),
                                    );
                                  }
                                } catch (_) {
                                  setSheetState(() => saving = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No pudimos guardar el cliente. Intenta de nuevo.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? 'Guardar cambios' : 'Crear cliente',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
