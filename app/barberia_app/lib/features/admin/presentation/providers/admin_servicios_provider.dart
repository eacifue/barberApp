import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../servicios/domain/servicio_model.dart';
import '../../data/admin_barberia_repository_helper.dart';
import '../../data/admin_servicio_repository.dart';

class AdminServiciosTabData {
  const AdminServiciosTabData({required this.barberiaId, required this.servicios});

  final String? barberiaId;
  final List<ServicioModel> servicios;
}

final adminServiciosTabProvider = FutureProvider.autoDispose<AdminServiciosTabData>((
  ref,
) async {
  final barberiaId = await ref.watch(adminBarberiaIdProvider.future);
  if (barberiaId == null) {
    return const AdminServiciosTabData(barberiaId: null, servicios: []);
  }

  final servicios = await ref
      .watch(adminServicioRepositoryProvider)
      .getServiciosPorBarberia(barberiaId);
  return AdminServiciosTabData(barberiaId: barberiaId, servicios: servicios);
});
