import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../domain/barbero_model.dart';

class BarberoRepository {
  const BarberoRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BarberoModel>> getBarberosPorServicio(String servicioId) async {
    if (servicioId.trim().isEmpty) {
      throw ValidationException(
        'Debes seleccionar un servicio para consultar barberos.',
      );
    }

    final response = await _apiClient.getList<List<BarberoModel>>(
      ApiEndpoints.barberosPorServicio(servicioId),
      fromJson: (list) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(BarberoModel.fromJson)
            .toList();
      },
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible cargar los barberos del servicio.'
            : response.message,
      );
    }

    return response.data ?? const [];
  }

  /// Equipo de la barbería (público): para «Nuestros barberos» en Inicio.
  Future<List<BarberoModel>> getBarberosPorBarberia(String barberiaId) async {
    final response = await _apiClient.getList<List<BarberoModel>>(
      ApiEndpoints.barberosPorBarberia(barberiaId),
      fromJson: (list) => list.whereType<Map<String, dynamic>>().map(BarberoModel.fromJson).toList(),
    );
    if (!response.success) {
      throw AppException(response.message.isEmpty ? 'No fue posible cargar los barberos.' : response.message);
    }
    return response.data ?? const [];
  }
}
