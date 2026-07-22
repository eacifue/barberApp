import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/barberia_card.dart';
import '../../data/admin_repository.dart';
import '../../data/models/admin_cliente_model.dart';

class AdminClientesTab extends ConsumerStatefulWidget {
  const AdminClientesTab({super.key});

  @override
  ConsumerState<AdminClientesTab> createState() => _AdminClientesTabState();
}

class _AdminClientesTabState extends ConsumerState<AdminClientesTab> {
  late Future<List<AdminClienteModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(adminRepositoryProvider).getClientes();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ref.read(adminRepositoryProvider).getClientes();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminClienteModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorState(
            message: snapshot.error.toString(),
            onRetry: _reload,
          );
        }

        final items = snapshot.data ?? const [];

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () async {
                    final created = await _showClienteCreateForm(context);
                    if (created == true) {
                      await _reload();
                    }
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Nuevo cliente'),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const _EmptyState(message: 'No hay clientes registrados.')
              else
                for (final item in items) ...[
                  BarberiaCard(
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
                            onPressed: () async {
                              final updated = await _showClienteEditForm(
                                context,
                                cliente: item,
                              );
                              if (updated == true) {
                                await _reload();
                              }
                            },
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

                                    if (confirmed == true) {
                                      await ref
                                          .read(adminRepositoryProvider)
                                          .deleteCliente(item.id);
                                      await _reload();
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

  Future<bool?> _showClienteCreateForm(BuildContext context) {
    final nombreController = TextEditingController();
    final apellidoController = TextEditingController();
    final telefonoController = TextEditingController();
    final correoController = TextEditingController();
    final passwordController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
                    'Nuevo cliente',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: apellidoController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Requerido';
                    if (text.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) {
                        return;
                      }

                      await ref
                          .read(adminRepositoryProvider)
                          .createCliente(
                            nombre: nombreController.text.trim(),
                            apellido: apellidoController.text.trim(),
                            telefono: telefonoController.text.trim(),
                            correo: correoController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const Text('Crear cliente'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showClienteEditForm(
    BuildContext context, {
    required AdminClienteModel cliente,
  }) {
    final nombreController = TextEditingController(text: cliente.nombre);
    final apellidoController = TextEditingController(text: cliente.apellido);
    final telefonoController = TextEditingController(text: cliente.telefono);
    final correoController = TextEditingController(text: cliente.correo);
    final passwordController = TextEditingController();
    var activo = cliente.activo;

    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
                    'Editar cliente',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: apellidoController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña (opcional)',
                  ),
                  obscureText: true,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    if (text.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                StatefulBuilder(
                  builder: (context, setInnerState) {
                    return SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Activo'),
                      value: activo,
                      onChanged: cliente.rol.toLowerCase() == 'admin'
                          ? null
                          : (value) => setInnerState(() => activo = value),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) {
                        return;
                      }

                      await ref
                          .read(adminRepositoryProvider)
                          .updateCliente(
                            id: cliente.id,
                            nombre: nombreController.text.trim(),
                            apellido: apellidoController.text.trim(),
                            telefono: telefonoController.text.trim(),
                            correo: correoController.text.trim(),
                            password: passwordController.text.trim().isEmpty
                                ? null
                                : passwordController.text.trim(),
                            activo: activo,
                          );

                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Text(message)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ocurrió un error', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }
}
