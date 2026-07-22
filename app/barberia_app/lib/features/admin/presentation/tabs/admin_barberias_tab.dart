import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/barberia_card.dart';
import '../../data/admin_repository.dart';
import '../../data/models/admin_barberia_model.dart';

class AdminBarberiasTab extends ConsumerStatefulWidget {
  const AdminBarberiasTab({super.key});

  @override
  ConsumerState<AdminBarberiasTab> createState() => _AdminBarberiasTabState();
}

class _AdminBarberiasTabState extends ConsumerState<AdminBarberiasTab> {
  late Future<List<AdminBarberiaModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(adminRepositoryProvider).getBarberias();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ref.read(adminRepositoryProvider).getBarberias();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminBarberiaModel>>(
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
                    final created = await _showBarberiaForm(context);
                    if (created == true) {
                      await _reload();
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nueva barbería'),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const _EmptyState(message: 'No hay barberías registradas.')
              else
                for (final item in items) ...[
                  BarberiaCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.nombre),
                      subtitle: Text('${item.direccion} · ${item.ciudad}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          Icon(
                            item.activa
                                ? Icons.check_circle_outline
                                : Icons.pause_circle_outline,
                            color: item.activa
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                          ),
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () async {
                              final updated = await _showBarberiaForm(
                                context,
                                barberia: item,
                              );
                              if (updated == true) {
                                await _reload();
                              }
                            },
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar barbería'),
                                  content: Text('¿Eliminar "${item.nombre}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await ref
                                    .read(adminRepositoryProvider)
                                    .deleteBarberia(item.id);
                                await _reload();
                              }
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
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

  Future<bool?> _showBarberiaForm(
    BuildContext context, {
    AdminBarberiaModel? barberia,
  }) {
    final isEdit = barberia != null;
    final barberiaId = barberia?.id;

    final nombreController = TextEditingController(
      text: barberia?.nombre ?? '',
    );
    final telefonoController = TextEditingController(
      text: barberia?.telefono ?? '',
    );
    final correoController = TextEditingController(
      text: barberia?.correo ?? '',
    );
    final direccionController = TextEditingController(
      text: barberia?.direccion ?? '',
    );
    final ciudadController = TextEditingController(
      text: barberia?.ciudad ?? '',
    );
    final departamentoController = TextEditingController(
      text: barberia?.departamento ?? '',
    );
    var activa = barberia?.activa ?? true;

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
                    isEdit ? 'Editar barbería' : 'Nueva barbería',
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
                  controller: direccionController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ciudadController,
                  decoration: const InputDecoration(labelText: 'Ciudad'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: departamentoController,
                  decoration: const InputDecoration(labelText: 'Departamento'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 4),
                StatefulBuilder(
                  builder: (context, setInnerState) {
                    return SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Activa'),
                      value: activa,
                      onChanged: (value) => setInnerState(() => activa = value),
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

                      final payload = {
                        'nombre': nombreController.text.trim(),
                        'descripcion': '',
                        'slogan': '',
                        'telefono': telefonoController.text.trim(),
                        'correo': correoController.text.trim(),
                        'sitioWeb': '',
                        'direccion': direccionController.text.trim(),
                        'ciudad': ciudadController.text.trim(),
                        'departamento': departamentoController.text.trim(),
                        'latitud': 0,
                        'longitud': 0,
                        'fotoPortada': '',
                        'horaApertura': '09:00:00',
                        'horaCierre': '18:00:00',
                        'diasDescanso': <String>[],
                        'activa': activa,
                      };

                      final repo = ref.read(adminRepositoryProvider);
                      if (isEdit) {
                        await repo.updateBarberia(barberiaId!, payload);
                      } else {
                        await repo.createBarberia(payload);
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Text(isEdit ? 'Guardar cambios' : 'Crear barbería'),
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
