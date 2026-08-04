import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../servicios/domain/servicio_model.dart';

final adminServicioRepositoryProvider = Provider<AdminServicioRepository>((
  ref,
) {
  return AdminServicioRepository(ref.watch(apiClientProvider));
});

class AdminServicioRepository {
  const AdminServicioRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ServicioModel>> getServiciosPorBarberia(String barberiaId) async {
    final response = await _apiClient.getList<List<ServicioModel>>(
      ApiEndpoints.serviciosPorBarberia(barberiaId),
      fromJson: (list) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ServicioModel.fromJson)
            .toList();
      },
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible cargar servicios.'
            : response.message,
      );
    }

    return response.data ?? const [];
  }

  Future<ServicioModel> createServicio({
    required String nombre,
    required String descripcion,
    required String tipo,
    required int duracionMinutos,
    required double precio,
    String? fotoUrl,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.servicios,
      data: {
        'nombre': nombre,
        'descripcion': descripcion,
        'tipo': tipo,
        'duracionMinutos': duracionMinutos,
        'precio': precio,
        'fotoUrl': fotoUrl,
      },
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible crear servicio.'
            : response.message,
      );
    }

    return ServicioModel.fromJson(response.data!);
  }

  Future<ServicioModel> updateServicio({
    required String id,
    required String nombre,
    required String descripcion,
    required String tipo,
    required int duracionMinutos,
    required double precio,
    String? fotoUrl,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.servicioPorId(id),
      data: {
        'nombre': nombre,
        'descripcion': descripcion,
        'tipo': tipo,
        'duracionMinutos': duracionMinutos,
        'precio': precio,
        'fotoUrl': fotoUrl,
      },
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible actualizar servicio.'
            : response.message,
      );
    }

    return ServicioModel.fromJson(response.data!);
  }

  Future<void> deleteServicio(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.servicioPorId(id),
      fromJson: (json) => json,
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible eliminar servicio.'
            : response.message,
      );
    }
  }
}
