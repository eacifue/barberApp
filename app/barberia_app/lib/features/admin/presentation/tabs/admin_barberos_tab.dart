import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/admin_empty_state.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../barberos/domain/barbero_model.dart';
import '../../../servicios/domain/servicio_model.dart';
import '../../data/admin_barbero_repository.dart';
import '../providers/admin_barberos_provider.dart';

class AdminBarberosTab extends ConsumerWidget {
  const AdminBarberosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(adminBarberosTabProvider);

    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => BarberiaErrorWidget(
        message: error is AppException
            ? error.message
            : 'No pudimos cargar los barberos.',
        onRetry: () => ref.invalidate(adminBarberosTabProvider),
      ),
      data: (data) {
        if (data.barberiaId == null) {
          return const AdminEmptyState(
            message: 'Crea una barbería primero para administrar barberos.',
          );
        }

        final items = data.barberos;

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminBarberosTabProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: data.servicios.isEmpty
                      ? null
                      : () => _showBarberoForm(
                          context,
                          ref,
                          servicios: data.servicios,
                        ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo barbero'),
                ),
              ),
              const SizedBox(height: 12),
              if (data.servicios.isEmpty)
                const AdminEmptyState(
                  message: 'Crea al menos un servicio antes de crear barberos.',
                )
              else if (items.isEmpty)
                const AdminEmptyState(
                  message: 'No hay barberos para esta barbería.',
                )
              else
                for (final item in items) ...[
                  AppCard(
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
                            onPressed: () => _showBarberoForm(
                              context,
                              ref,
                              servicios: data.servicios,
                              barbero: item,
                            ),
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

                              if (confirmed != true) {
                                return;
                              }

                              try {
                                await ref
                                    .read(adminBarberoRepositoryProvider)
                                    .deleteBarbero(item.id);
                                ref.invalidate(adminBarberosTabProvider);
                              } on AppException catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.message)),
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No pudimos eliminar el barbero. Intenta de nuevo.',
                                      ),
                                    ),
                                  );
                                }
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

  Future<void> _showBarberoForm(
    BuildContext context,
    WidgetRef ref, {
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

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        var saving = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Biografía',
                        ),
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
                      Column(
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
                                setSheetState(() {
                                  if (checked == true) {
                                    selectedServicioIds.add(servicio.id);
                                  } else {
                                    selectedServicioIds.remove(servicio.id);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
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

                                  final especialidades =
                                      especialidadesController.text
                                          .split(',')
                                          .map((e) => e.trim())
                                          .where((e) => e.isNotEmpty)
                                          .toList();

                                  setSheetState(() => saving = true);
                                  try {
                                    final repo = ref.read(
                                      adminBarberoRepositoryProvider,
                                    );

                                    if (isEdit) {
                                      await repo.updateBarbero(
                                        id: barberoId!,
                                        nombre: nombreController.text.trim(),
                                        apellido: apellidoController.text
                                            .trim(),
                                        telefono: telefonoController.text
                                            .trim(),
                                        correo: correoController.text.trim(),
                                        biografia: biografiaController.text
                                            .trim(),
                                        aniosExperiencia: int.parse(
                                          experienciaController.text.trim(),
                                        ),
                                        especialidades: especialidades,
                                        servicioIds: selectedServicioIds
                                            .toList(),
                                        fotoUrl:
                                            fotoController.text.trim().isEmpty
                                            ? null
                                            : fotoController.text.trim(),
                                      );
                                    } else {
                                      await repo.createBarbero(
                                        nombre: nombreController.text.trim(),
                                        apellido: apellidoController.text
                                            .trim(),
                                        telefono: telefonoController.text
                                            .trim(),
                                        correo: correoController.text.trim(),
                                        biografia: biografiaController.text
                                            .trim(),
                                        aniosExperiencia: int.parse(
                                          experienciaController.text.trim(),
                                        ),
                                        especialidades: especialidades,
                                        servicioIds: selectedServicioIds
                                            .toList(),
                                        fotoUrl:
                                            fotoController.text.trim().isEmpty
                                            ? null
                                            : fotoController.text.trim(),
                                      );
                                    }

                                    ref.invalidate(adminBarberosTabProvider);
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  } on AppException catch (e) {
                                    setSheetState(() => saving = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.message)),
                                      );
                                    }
                                  } catch (_) {
                                    setSheetState(() => saving = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'No pudimos guardar el barbero. Intenta de nuevo.',
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
                                  isEdit ? 'Guardar cambios' : 'Crear barbero',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
