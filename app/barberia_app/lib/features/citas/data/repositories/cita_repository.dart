import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../domain/models/cita_model.dart';

class CitaRepository {
  const CitaRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CitaModel> crearCita(CrearCitaRequestModel request) async {
    final response = await _apiClient.post<CitaModel>(
      ApiEndpoints.citas,
      data: {
        'barberoId': request.barberoId,
        'servicioId': request.servicioId,
        'fechaCita': request.fechaCita.toApiDate,
        'horaInicio': request.horaInicio,
        'tokenRedisBloqueo': request.tokenRedisBloqueo,
        'notas': request.notas,
      },
      fromJson: CitaModel.fromJson,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No se pudo crear la cita.'
            : response.message,
      );
    }

    return response.data!;
  }

  Future<List<CitaModel>> getMisCitas(String barberiaId) async {
    if (barberiaId.trim().isEmpty) {
      throw ValidationException(
        'Debes seleccionar una barbería para consultar tus citas.',
      );
    }

    final response = await _apiClient.getList<List<CitaModel>>(
      '${ApiEndpoints.citas}/mis-citas',
      queryParams: {'barberiaId': barberiaId},
      fromJson: (list) => list
          .whereType<Map<String, dynamic>>()
          .map(CitaModel.fromJson)
          .toList(),
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No se pudieron cargar tus citas.'
            : response.message,
      );
    }

    return response.data ?? const [];
  }

  Future<CitaModel> getCitaById(String citaId) async {
    final response = await _apiClient.get<CitaModel>(
      ApiEndpoints.citaPorId(citaId),
      fromJson: CitaModel.fromJson,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No se pudo cargar la cita.'
            : response.message,
      );
    }

    return response.data!;
  }

  Future<CitaModel> cancelarCita(String citaId, {String? motivo}) async {
    final response = await _apiClient.put<CitaModel>(
      ApiEndpoints.cancelarCita(citaId),
      data: {'motivo': motivo},
      fromJson: CitaModel.fromJson,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No se pudo cancelar la cita.'
            : response.message,
      );
    }

    return response.data!;
  }
}
