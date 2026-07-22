import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/cita_repository.dart';
import '../../domain/models/cita_model.dart';

final citaRepositoryProvider = Provider<CitaRepository>((ref) {
  return CitaRepository(ref.watch(apiClientProvider));
});

final misCitasProvider = FutureProvider.family<List<CitaModel>, String>((
  ref,
  barberiaId,
) async {
  final repository = ref.watch(citaRepositoryProvider);
  return repository.getMisCitas(barberiaId);
});

final citaByIdProvider = FutureProvider.family<CitaModel, String>((
  ref,
  citaId,
) async {
  final repository = ref.watch(citaRepositoryProvider);
  return repository.getCitaById(citaId);
});
