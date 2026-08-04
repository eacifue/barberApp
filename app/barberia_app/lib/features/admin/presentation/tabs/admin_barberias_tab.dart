import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/admin_empty_state.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../data/admin_repository.dart';
import '../../data/models/admin_barberia_model.dart';
import '../providers/admin_barberias_provider.dart';

class AdminBarberiasTab extends ConsumerWidget {
  const AdminBarberiasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barberiasAsync = ref.watch(adminBarberiasProvider);

    return barberiasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => BarberiaErrorWidget(
        message: error is AppException
            ? error.message
            : 'No pudimos cargar las barberías.',
        onRetry: () => ref.invalidate(adminBarberiasProvider),
      ),
      data: (items) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminBarberiasProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _showBarberiaForm(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nueva barbería'),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const AdminEmptyState(message: 'No hay barberías registradas.')
              else
                for (final item in items) ...[
                  AppCard(
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
                            onPressed: () =>
                                _showBarberiaForm(context, ref, barberia: item),
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

                              if (confirmed != true) {
                                return;
                              }

                              try {
                                await ref
                                    .read(adminRepositoryProvider)
                                    .deleteBarberia(item.id);
                                ref.invalidate(adminBarberiasProvider);
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
                                        'No pudimos eliminar la barbería. Intenta de nuevo.',
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

  Future<void> _showBarberiaForm(
    BuildContext context,
    WidgetRef ref, {
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
                        isEdit ? 'Editar barbería' : 'Nueva barbería',
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
                      controller: direccionController,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: ciudadController,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: departamentoController,
                      decoration: const InputDecoration(
                        labelText: 'Departamento',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Activa'),
                      value: activa,
                      onChanged: (value) => setSheetState(() => activa = value),
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

                                final payload = {
                                  'nombre': nombreController.text.trim(),
                                  'descripcion': '',
                                  'slogan': '',
                                  'telefono': telefonoController.text.trim(),
                                  'correo': correoController.text.trim(),
                                  'sitioWeb': '',
                                  'direccion': direccionController.text.trim(),
                                  'ciudad': ciudadController.text.trim(),
                                  'departamento': departamentoController.text
                                      .trim(),
                                  'latitud': 0,
                                  'longitud': 0,
                                  'fotoPortada': '',
                                  'horaApertura': '09:00:00',
                                  'horaCierre': '18:00:00',
                                  'diasDescanso': <String>[],
                                  'activa': activa,
                                };

                                setSheetState(() => saving = true);
                                try {
                                  final repo = ref.read(adminRepositoryProvider);
                                  if (isEdit) {
                                    await repo.updateBarberia(
                                      barberiaId!,
                                      payload,
                                    );
                                  } else {
                                    await repo.createBarberia(payload);
                                  }

                                  ref.invalidate(adminBarberiasProvider);
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
                                          'No pudimos guardar la barbería. Intenta de nuevo.',
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
                                isEdit ? 'Guardar cambios' : 'Crear barbería',
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
