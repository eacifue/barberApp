import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../barberos/domain/barbero_model.dart';
import '../../../servicios/domain/servicio_model.dart';
import '../../data/admin_barberia_repository_helper.dart';
import '../../data/admin_barbero_repository.dart';
import '../../data/admin_servicio_repository.dart';

class AdminBarberosTabData {
  const AdminBarberosTabData({
    required this.barberiaId,
    required this.barberos,
    required this.servicios,
  });

  final String? barberiaId;
  final List<BarberoModel> barberos;
  final List<ServicioModel> servicios;
}

final adminBarberosTabProvider = FutureProvider.autoDispose<AdminBarberosTabData>((
  ref,
) async {
  final barberiaId = await ref.watch(adminBarberiaIdProvider.future);
  if (barberiaId == null) {
    return const AdminBarberosTabData(barberiaId: null, barberos: [], servicios: []);
  }

  final barberosRepo = ref.watch(adminBarberoRepositoryProvider);
  final serviciosRepo = ref.watch(adminServicioRepositoryProvider);

  final results = await Future.wait([
    barberosRepo.getBarberosPorBarberia(barberiaId),
    serviciosRepo.getServiciosPorBarberia(barberiaId),
  ]);

  return AdminBarberosTabData(
    barberiaId: barberiaId,
    barberos: results[0] as List<BarberoModel>,
    servicios: results[1] as List<ServicioModel>,
  );
});
