import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/api_client.dart';
import '../../data/barbero_repository.dart';
import '../../domain/barbero_model.dart';

part 'barberos_provider.g.dart';

final barberoRepositoryProvider = Provider<BarberoRepository>((ref) {
  return BarberoRepository(ref.watch(apiClientProvider));
});

@riverpod
Future<List<BarberoModel>> barberosPorServicio(
  BarberosPorServicioRef ref,
  String servicioId,
) async {
  final repository = ref.watch(barberoRepositoryProvider);
  return repository.getBarberosPorServicio(servicioId);
}

/// Barberos activos de la barbería (Inicio · «Nuestros barberos»).
final barberosDeLaBarberiaProvider = FutureProvider.family<List<BarberoModel>, String>((ref, barberiaId) async {
  final barberos = await ref.watch(barberoRepositoryProvider).getBarberosPorBarberia(barberiaId);
  return barberos.where((b) => b.activo).toList();
});
