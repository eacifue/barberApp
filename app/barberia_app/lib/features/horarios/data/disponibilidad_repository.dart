import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../../shared/extensions/date_extensions.dart';
import '../domain/disponibilidad_model.dart';

class DisponibilidadRepository {
  const DisponibilidadRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DisponibilidadModel> getSlots({
    required String barberoId,
    required String servicioId,
    required DateTime fecha,
  }) async {
    final response = await _apiClient.get<DisponibilidadModel>(
      ApiEndpoints.disponibilidadBarbero(barberoId),
      queryParams: {'servicioId': servicioId, 'fecha': fecha.toApiDate},
      fromJson: DisponibilidadModel.fromJson,
    );

    final data = response.data;
    if (!response.success || data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible consultar la disponibilidad.'
            : response.message,
      );
    }

    return data;
  }
}
