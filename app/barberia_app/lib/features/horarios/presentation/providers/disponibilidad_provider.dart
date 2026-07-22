import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/api_client.dart';
import '../../data/bloqueo_repository.dart';
import '../../data/disponibilidad_repository.dart';
import '../../domain/disponibilidad_model.dart';
import 'disponibilidad_notifier.dart';
import 'disponibilidad_state.dart';

part 'disponibilidad_provider.g.dart';

final disponibilidadRepositoryProvider = Provider<DisponibilidadRepository>((
  ref,
) {
  return DisponibilidadRepository(ref.watch(apiClientProvider));
});

final bloqueoRepositoryProvider = Provider<BloqueoRepository>((ref) {
  return BloqueoRepository(ref.watch(apiClientProvider));
});

@riverpod
Future<DisponibilidadModel> disponibilidad(
  DisponibilidadRef ref, {
  required String barberoId,
  required String servicioId,
  required DateTime fecha,
}) async {
  final repository = ref.watch(disponibilidadRepositoryProvider);
  return repository.getSlots(
    barberoId: barberoId,
    servicioId: servicioId,
    fecha: fecha,
  );
}

final disponibilidadNotifierProvider =
    StateNotifierProvider<DisponibilidadNotifier, DisponibilidadState>((ref) {
      return DisponibilidadNotifier(ref);
    });
