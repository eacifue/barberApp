import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_repository.dart';

/// Devuelve el id de la primera barbería (activa o no) para simplificar
/// la administración de barberos/servicios cuando el proyecto solo maneja 1 barbería.
final adminBarberiaIdProvider = FutureProvider<String?>((ref) async {
  final barberias = await ref.watch(adminRepositoryProvider).getBarberias();
  if (barberias.isEmpty) return null;
  return barberias.first.id;
});
