import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../data/admin_repository.dart';
import '../../data/models/admin_barberia_model.dart';
import '../providers/admin_barberias_provider.dart';

const _diasSemana = [
  'Lunes',
  'Martes',
  'Miercoles',
  'Jueves',
  'Viernes',
  'Sabado',
  'Domingo',
];

/// La app solo maneja una barbería, así que esta pestaña es un formulario de
/// configuración de "Mi barbería" — ver/editar, sin crear ni eliminar.
class AdminBarberiasTab extends ConsumerStatefulWidget {
  const AdminBarberiasTab({super.key});

  @override
  ConsumerState<AdminBarberiasTab> createState() => _AdminBarberiasTabState();
}

class _AdminBarberiasTabState extends ConsumerState<AdminBarberiasTab> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _horaAperturaController = TextEditingController();
  final _horaCierreController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  String? _loadedId;
  bool _activa = true;
  Set<String> _diasDescanso = {};
  bool _saving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _departamentoController.dispose();
    _horaAperturaController.dispose();
    _horaCierreController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  void _hydrate(AdminBarberiaModel barberia) {
    if (_loadedId == barberia.id) {
      return;
    }
    _loadedId = barberia.id;
    _nombreController.text = barberia.nombre;
    _telefonoController.text = barberia.telefono;
    _correoController.text = barberia.correo;
    _direccionController.text = barberia.direccion;
    _ciudadController.text = barberia.ciudad;
    _departamentoController.text = barberia.departamento;
    _horaAperturaController.text = _toHm(barberia.horaApertura);
    _horaCierreController.text = _toHm(barberia.horaCierre);
    _latitudController.text = barberia.latitud == 0
        ? ''
        : barberia.latitud.toString();
    _longitudController.text = barberia.longitud == 0
        ? ''
        : barberia.longitud.toString();
    _activa = barberia.activa;
    _diasDescanso = barberia.diasDescanso.toSet();
  }

  static String _toHm(String horaHms) {
    return horaHms.length >= 5 ? horaHms.substring(0, 5) : horaHms;
  }

  String? _validateHora(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Requerido';
    }
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value.trim())) {
      return 'Formato HH:mm';
    }
    return null;
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final parts = controller.text.split(':');
    final initial = parts.length == 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 9,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      controller.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final id = _loadedId;
    if (id == null) {
      return;
    }

    final payload = {
      'nombre': _nombreController.text.trim(),
      'descripcion': '',
      'slogan': '',
      'telefono': _telefonoController.text.trim(),
      'correo': _correoController.text.trim(),
      'sitioWeb': '',
      'direccion': _direccionController.text.trim(),
      'ciudad': _ciudadController.text.trim(),
      'departamento': _departamentoController.text.trim(),
      'latitud': double.tryParse(_latitudController.text.trim()) ?? 0,
      'longitud': double.tryParse(_longitudController.text.trim()) ?? 0,
      'fotoPortada': '',
      'horaApertura': '${_horaAperturaController.text.trim()}:00',
      'horaCierre': '${_horaCierreController.text.trim()}:00',
      'diasDescanso': _diasDescanso.toList(),
      'activa': _activa,
    };

    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateBarberia(id, payload);
      ref.invalidate(adminBarberiasProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barbería actualizada correctamente.')),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos guardar los cambios. Intenta de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final barberiasAsync = ref.watch(adminBarberiasProvider);

    return barberiasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => BarberiaErrorWidget(
        message: error is AppException
            ? error.message
            : 'No pudimos cargar tu barbería.',
        onRetry: () => ref.invalidate(adminBarberiasProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No hay una barbería configurada. Contacta a soporte.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        _hydrate(items.first);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi barbería',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Esta información es la que ven tus clientes en la app.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ciudadController,
                        decoration: const InputDecoration(labelText: 'Ciudad'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _departamentoController,
                        decoration: const InputDecoration(
                          labelText: 'Departamento',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Horario de atención',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _horaAperturaController,
                        decoration: const InputDecoration(
                          labelText: 'Apertura',
                        ),
                        readOnly: true,
                        validator: _validateHora,
                        onTap: () => _pickTime(_horaAperturaController),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _horaCierreController,
                        decoration: const InputDecoration(labelText: 'Cierre'),
                        readOnly: true,
                        validator: _validateHora,
                        onTap: () => _pickTime(_horaCierreController),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Días de descanso',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final dia in _diasSemana)
                      FilterChip(
                        label: Text(dia),
                        selected: _diasDescanso.contains(dia),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _diasDescanso.add(dia);
                          } else {
                            _diasDescanso.remove(dia);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Ubicación en el mapa',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudController,
                        decoration: const InputDecoration(
                          labelText: 'Latitud (opcional)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudController,
                        decoration: const InputDecoration(
                          labelText: 'Longitud (opcional)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activa'),
                  value: _activa,
                  onChanged: (value) => setState(() => _activa = value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar cambios'),
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
