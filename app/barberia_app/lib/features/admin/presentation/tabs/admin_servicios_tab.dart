import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/admin_empty_state.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../servicios/domain/servicio_model.dart';
import '../../data/admin_servicio_repository.dart';
import '../providers/admin_servicios_provider.dart';

class AdminServiciosTab extends ConsumerWidget {
  const AdminServiciosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(adminServiciosTabProvider);

    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => BarberiaErrorWidget(
        message: error is AppException
            ? error.message
            : 'No pudimos cargar los servicios.',
        onRetry: () => ref.invalidate(adminServiciosTabProvider),
      ),
      data: (data) {
        if (data.barberiaId == null) {
          return const AdminEmptyState(
            message: 'Crea una barbería primero para administrar servicios.',
          );
        }

        final items = data.servicios;

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminServiciosTabProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _showServicioForm(
                    context,
                    ref,
                    barberiaId: data.barberiaId!,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo servicio'),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const AdminEmptyState(
                  message: 'No hay servicios para esta barbería.',
                )
              else
                for (final item in items) ...[
                  AppCard(
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
                            onPressed: () => _showServicioForm(
                              context,
                              ref,
                              barberiaId: data.barberiaId!,
                              servicio: item,
                            ),
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

                              if (confirmed != true) {
                                return;
                              }

                              try {
                                await ref
                                    .read(adminServicioRepositoryProvider)
                                    .deleteServicio(item.id);
                                ref.invalidate(adminServiciosTabProvider);
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
                                        'No pudimos eliminar el servicio. Intenta de nuevo.',
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

  Future<void> _showServicioForm(
    BuildContext context,
    WidgetRef ref, {
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
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: tipoController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo (Corte, Barba, ... )',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
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
                        onPressed: saving
                            ? null
                            : () async {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }

                                final duracion = int.parse(
                                  duracionController.text.trim(),
                                );
                                final precio = double.parse(
                                  precioController.text.trim(),
                                );

                                setSheetState(() => saving = true);
                                try {
                                  final repo = ref.read(
                                    adminServicioRepositoryProvider,
                                  );
                                  if (isEdit) {
                                    await repo.updateServicio(
                                      id: servicioId!,
                                      barberiaId: barberiaId,
                                      nombre: nombreController.text.trim(),
                                      descripcion: descripcionController.text
                                          .trim(),
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
                                      descripcion: descripcionController.text
                                          .trim(),
                                      tipo: tipoController.text.trim(),
                                      duracionMinutos: duracion,
                                      precio: precio,
                                      fotoUrl: fotoController.text.trim().isEmpty
                                          ? null
                                          : fotoController.text.trim(),
                                    );
                                  }

                                  ref.invalidate(adminServiciosTabProvider);
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
                                          'No pudimos guardar el servicio. Intenta de nuevo.',
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
                                isEdit ? 'Guardar cambios' : 'Crear servicio',
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
