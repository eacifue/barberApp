import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../domain/barbershop_model.dart';

/// La barbería donde reserva este dispositivo. El nombre puede venir vacío si
/// se recuperó solo del token de una sesión abierta.
class BarberiaElegida {
  const BarberiaElegida({required this.id, required this.nombre});

  final String id;
  final String nombre;
}

final barberiaElegidaProvider = AsyncNotifierProvider<BarberiaElegidaNotifier, BarberiaElegida?>(BarberiaElegidaNotifier.new);

class BarberiaElegidaNotifier extends AsyncNotifier<BarberiaElegida?> {
  SecureStorageService get _storage => ref.read(secureStorageProvider);

  @override
  Future<BarberiaElegida?> build() async {
    final storage = ref.watch(secureStorageProvider);
    final id = await storage.getBarberiaId();
    if (id == null || id.isEmpty) return null;
    return BarberiaElegida(id: id, nombre: await storage.getBarberiaNombre() ?? '');
  }

  Future<void> elegir(BarbershopModel barberia) async {
    await _storage.saveBarberia(id: barberia.id, nombre: barberia.nombre);
    state = AsyncData(BarberiaElegida(id: barberia.id, nombre: barberia.nombre));
  }

  /// «Cambiar de barbería». Quien tenga sesión debe cerrarla antes: la cuenta es de una sola barbería.
  Future<void> olvidar() async {
    await _storage.clearBarberia();
    state = const AsyncData(null);
  }
}
