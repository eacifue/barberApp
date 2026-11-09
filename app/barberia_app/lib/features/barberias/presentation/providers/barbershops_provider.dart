import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/barbershop_repository.dart';
import '../../domain/barbershop_model.dart';
import 'barberia_elegida_provider.dart';

/// Barberías activas que reciben reservas (para elegir una).
final barbershopsProvider = FutureProvider<List<BarbershopModel>>((ref) async {
  final repository = ref.watch(barbershopRepositoryProvider);
  return repository.getBarbershops();
});

/// La barbería elegida en este dispositivo, con sus datos. `null` si no hay una
/// elegida o si ya no recibe reservas.
final myBarbershopProvider = FutureProvider<BarbershopModel?>((ref) async {
  final elegida = await ref.watch(barberiaElegidaProvider.future);
  if (elegida == null) return null;
  final barbershops = await ref.watch(barbershopsProvider.future);
  return barbershops.where((b) => b.id == elegida.id).firstOrNull;
});
