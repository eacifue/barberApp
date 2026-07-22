import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../domain/servicio_model.dart';

class ServicioRepository {
  const ServicioRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ServicioModel>> getServicios(String barberiaId) async {
    if (barberiaId.trim().isEmpty) {
      throw ValidationException(
        'Debes indicar una barbería válida para consultar servicios.',
      );
    }

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
}
