import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/api_client.dart';
import '../../data/servicio_repository.dart';
import '../../domain/servicio_model.dart';

part 'servicios_provider.g.dart';

final servicioRepositoryProvider = Provider<ServicioRepository>((ref) {
  return ServicioRepository(ref.watch(apiClientProvider));
});

@riverpod
Future<List<ServicioModel>> servicios(
  ServiciosRef ref,
  String barberiaId,
) async {
  final repository = ref.watch(servicioRepositoryProvider);
  return repository.getServicios(barberiaId);
}
