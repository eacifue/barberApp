import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/auth/jwt_utils.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
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

/// Agenda del día del barbero que inició sesión (claim `barberoId` del JWT).
final agendaBarberoProvider = FutureProvider.autoDispose.family<List<CitaModel>, DateTime>((ref, fecha) async {
  final token = await ref.watch(secureStorageProvider).getToken();
  final barberoId = token == null ? null : JwtUtils.tryGetBarberoId(token);
  if (barberoId == null) {
    throw AppException('Tu cuenta no está vinculada a un barbero. Pide a recepción que la vincule en Usuarios.');
  }
  final citas = await ref.watch(citaRepositoryProvider).getAgendaBarbero(barberoId, fecha);
  return [...citas]..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
});
