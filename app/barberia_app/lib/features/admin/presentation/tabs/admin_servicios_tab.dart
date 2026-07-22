import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/barberia_card.dart';
import '../../../servicios/domain/servicio_model.dart';
import '../../data/admin_barberia_repository_helper.dart';
import '../../data/admin_servicio_repository.dart';

class AdminServiciosTab extends ConsumerStatefulWidget {
  const AdminServiciosTab({super.key});

  @override
  ConsumerState<AdminServiciosTab> createState() => _AdminServiciosTabState();
}

class _AdminServiciosTabState extends ConsumerState<AdminServiciosTab> {
  late Future<_TabData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TabData> _load() async {
    final barberiaId = await ref.read(adminBarberiaIdProvider.future);
    if (barberiaId == null) {
      return const _TabData(barberiaId: null, servicios: []);
    }

    final servicios = await ref
        .read(adminServicioRepositoryProvider)
        .getServiciosPorBarberia(barberiaId);
    return _TabData(barberiaId: barberiaId, servicios: servicios);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TabData>(
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

        final data =
            snapshot.data ?? const _TabData(barberiaId: null, servicios: []);

        if (data.barberiaId == null) {
          return const _EmptyState(
            message: 'Crea una barbería primero para administrar servicios.',
          );
        }

        final items = data.servicios;

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () async {
                    final created = await _showServicioForm(
                      context,
                      barberiaId: data.barberiaId!,
                    );
                    if (created == true) {
                      await _reload();
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo servicio'),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const _EmptyState(
                  message: 'No hay servicios para esta barbería.',
                )
              else
                for (final item in items) ...[
                  BarberiaCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.nombre),
                      subtitle: Text(
                        '${item.duracionFormateada} · ${item.precioFormateado}',
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () async {
                              final updated = await _showServicioForm(
                                context,
                                barberiaId: data.barberiaId!,
                                servicio: item,
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
                                  title: const Text('Eliminar servicio'),
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
                                    .read(adminServicioRepositoryProvider)
                                    .deleteServicio(item.id);
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

  Future<bool?> _showServicioForm(
    BuildContext context, {
    required String barberiaId,
    ServicioModel? servicio,
  }) {
    final isEdit = servicio != null;
    final servicioId = servicio?.id;

    final nombreController = TextEditingController(
      text: servicio?.nombre ?? '',
    );
    final descripcionController = TextEditingController(
      text: servicio?.descripcion ?? '',
    );
    final tipoController = TextEditingController(
      text: servicio?.tipo ?? 'Otro',
    );
    final duracionController = TextEditingController(
      text: servicio?.duracionMinutos.toString() ?? '30',
    );
    final precioController = TextEditingController(
      text: servicio?.precio.toStringAsFixed(0) ?? '0',
    );
    final fotoController = TextEditingController(text: servicio?.fotoUrl ?? '');

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
                    isEdit ? 'Editar servicio' : 'Nuevo servicio',
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
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: tipoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo (Corte, Barba, ... )',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: duracionController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (min)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed < 0) return 'Inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fotoController,
                  decoration: const InputDecoration(
                    labelText: 'Foto URL (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;

                      final repo = ref.read(adminServicioRepositoryProvider);
                      final duracion = int.parse(
                        duracionController.text.trim(),
                      );
                      final precio = double.parse(precioController.text.trim());

                      if (isEdit) {
                        await repo.updateServicio(
                          id: servicioId!,
                          barberiaId: barberiaId,
                          nombre: nombreController.text.trim(),
                          descripcion: descripcionController.text.trim(),
                          tipo: tipoController.text.trim(),
                          duracionMinutos: duracion,
                          precio: precio,
                          fotoUrl: fotoController.text.trim().isEmpty
                              ? null
                              : fotoController.text.trim(),
                        );
                      } else {
                        await repo.createServicio(
                          barberiaId: barberiaId,
                          nombre: nombreController.text.trim(),
                          descripcion: descripcionController.text.trim(),
                          tipo: tipoController.text.trim(),
                          duracionMinutos: duracion,
                          precio: precio,
                          fotoUrl: fotoController.text.trim().isEmpty
                              ? null
                              : fotoController.text.trim(),
                        );
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Text(isEdit ? 'Guardar cambios' : 'Crear servicio'),
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

class _TabData {
  const _TabData({required this.barberiaId, required this.servicios});

  final String? barberiaId;
  final List<ServicioModel> servicios;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
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
