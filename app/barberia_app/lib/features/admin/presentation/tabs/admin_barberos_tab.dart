import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/barberia_card.dart';
import '../../../barberos/domain/barbero_model.dart';
import '../../../servicios/domain/servicio_model.dart';
import '../../data/admin_barberia_repository_helper.dart';
import '../../data/admin_barbero_repository.dart';
import '../../data/admin_servicio_repository.dart';

class AdminBarberosTab extends ConsumerStatefulWidget {
  const AdminBarberosTab({super.key});

  @override
  ConsumerState<AdminBarberosTab> createState() => _AdminBarberosTabState();
}

class _AdminBarberosTabState extends ConsumerState<AdminBarberosTab> {
  late Future<_TabData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TabData> _load() async {
    final barberiaId = await ref.read(adminBarberiaIdProvider.future);
    if (barberiaId == null) {
      return const _TabData(barberiaId: null, barberos: [], servicios: []);
    }

    final repo = ref.read(adminBarberoRepositoryProvider);
    final serviciosRepo = ref.read(adminServicioRepositoryProvider);

    final results = await Future.wait([
      repo.getBarberosPorBarberia(barberiaId),
      serviciosRepo.getServiciosPorBarberia(barberiaId),
    ]);

    return _TabData(
      barberiaId: barberiaId,
      barberos: results[0] as List<BarberoModel>,
      servicios: results[1] as List<ServicioModel>,
    );
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
            snapshot.data ??
            const _TabData(barberiaId: null, barberos: [], servicios: []);

        if (data.barberiaId == null) {
          return const _EmptyState(
            message: 'Crea una barbería primero para administrar barberos.',
          );
        }

        final items = data.barberos;

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: data.servicios.isEmpty
                      ? null
                      : () async {
                          final created = await _showBarberoForm(
                            context,
                            barberiaId: data.barberiaId!,
                            servicios: data.servicios,
                          );
                          if (created == true) {
                            await _reload();
                          }
                        },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo barbero'),
                ),
              ),
              const SizedBox(height: 12),
              if (data.servicios.isEmpty)
                const _EmptyState(
                  message: 'Crea al menos un servicio antes de crear barberos.',
                )
              else if (items.isEmpty)
                const _EmptyState(
                  message: 'No hay barberos para esta barbería.',
                )
              else
                for (final item in items) ...[
                  BarberiaCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.nombreCompleto),
                      subtitle: Text(
                        '${item.ratingText} · ${item.servicios.length} servicio(s)',
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () async {
                              final updated = await _showBarberoForm(
                                context,
                                barberiaId: data.barberiaId!,
                                servicios: data.servicios,
                                barbero: item,
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
                                  title: const Text('Eliminar barbero'),
                                  content: Text(
                                    '¿Eliminar "${item.nombreCompleto}"?',
                                  ),
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
                                    .read(adminBarberoRepositoryProvider)
                                    .deleteBarbero(item.id);
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

  Future<bool?> _showBarberoForm(
    BuildContext context, {
    required String barberiaId,
    required List<ServicioModel> servicios,
    BarberoModel? barbero,
  }) {
    final isEdit = barbero != null;
    final barberoId = barbero?.id;

    final nombreController = TextEditingController(text: barbero?.nombre ?? '');
    final apellidoController = TextEditingController(
      text: barbero?.apellido ?? '',
    );
    final telefonoController = TextEditingController(
      text: barbero?.telefono ?? '',
    );
    final correoController = TextEditingController(text: barbero?.correo ?? '');
    final biografiaController = TextEditingController(
      text: barbero?.biografia ?? '',
    );
    final experienciaController = TextEditingController(
      text: barbero?.aniosExperiencia.toString() ?? '0',
    );
    final especialidadesController = TextEditingController(
      text: (barbero?.especialidades ?? const []).join(', '),
    );
    final fotoController = TextEditingController(text: barbero?.fotoUrl ?? '');

    final selectedServicioIds = <String>{
      for (final s in (barbero?.servicios ?? const <ServicioModel>[])) s.id,
    };

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isEdit ? 'Editar barbero' : 'Nuevo barbero',
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
                    controller: biografiaController,
                    decoration: const InputDecoration(labelText: 'Biografía'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: experienciaController,
                    decoration: const InputDecoration(
                      labelText: 'Años de experiencia',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed < 0) return 'Inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: especialidadesController,
                    decoration: const InputDecoration(
                      labelText: 'Especialidades (separadas por coma)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fotoController,
                    decoration: const InputDecoration(
                      labelText: 'Foto URL (opcional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Servicios',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (context, setInnerState) {
                      return Column(
                        children: [
                          for (final servicio in servicios)
                            CheckboxListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(servicio.nombre),
                              subtitle: Text(
                                '${servicio.duracionFormateada} · ${servicio.precioFormateado}',
                              ),
                              value: selectedServicioIds.contains(servicio.id),
                              onChanged: (checked) {
                                setInnerState(() {
                                  if (checked == true) {
                                    selectedServicioIds.add(servicio.id);
                                  } else {
                                    selectedServicioIds.remove(servicio.id);
                                  }
                                });
                              },
                            ),
                        ],
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
                        if (selectedServicioIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Debes seleccionar al menos un servicio.',
                              ),
                            ),
                          );
                          return;
                        }

                        final especialidades = especialidadesController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                        final repo = ref.read(adminBarberoRepositoryProvider);

                        if (isEdit) {
                          await repo.updateBarbero(
                            id: barberoId!,
                            barberiaId: barberiaId,
                            nombre: nombreController.text.trim(),
                            apellido: apellidoController.text.trim(),
                            telefono: telefonoController.text.trim(),
                            correo: correoController.text.trim(),
                            biografia: biografiaController.text.trim(),
                            aniosExperiencia: int.parse(
                              experienciaController.text.trim(),
                            ),
                            especialidades: especialidades,
                            servicioIds: selectedServicioIds.toList(),
                            fotoUrl: fotoController.text.trim().isEmpty
                                ? null
                                : fotoController.text.trim(),
                          );
                        } else {
                          await repo.createBarbero(
                            barberiaId: barberiaId,
                            nombre: nombreController.text.trim(),
                            apellido: apellidoController.text.trim(),
                            telefono: telefonoController.text.trim(),
                            correo: correoController.text.trim(),
                            biografia: biografiaController.text.trim(),
                            aniosExperiencia: int.parse(
                              experienciaController.text.trim(),
                            ),
                            especialidades: especialidades,
                            servicioIds: selectedServicioIds.toList(),
                            fotoUrl: fotoController.text.trim().isEmpty
                                ? null
                                : fotoController.text.trim(),
                          );
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: Text(isEdit ? 'Guardar cambios' : 'Crear barbero'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabData {
  const _TabData({
    required this.barberiaId,
    required this.barberos,
    required this.servicios,
  });

  final String? barberiaId;
  final List<BarberoModel> barberos;
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
