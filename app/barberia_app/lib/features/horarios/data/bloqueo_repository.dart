import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../../shared/extensions/date_extensions.dart';
import '../domain/bloqueo_result_model.dart';

class BloqueoRepository {
  const BloqueoRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<BloqueoResultModel> bloquearSlot({
    required String barberoId,
    required String servicioId,
    required DateTime fecha,
    required TimeOfDay horaInicio,
  }) async {
    final response = await _apiClient.post<BloqueoResultModel>(
      ApiEndpoints.slotsBloquear,
      data: {
        'barberoId': barberoId,
        'servicioId': servicioId,
        'fechaCita': fecha.toApiDate,
        'horaInicio': _formatTime(horaInicio),
      },
      fromJson: BloqueoResultModel.fromJson,
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible bloquear el horario.'
            : response.message,
      );
    }

    return response.data ??
        const BloqueoResultModel(
          exitoso: false,
          mensajeError: 'No recibimos confirmación del bloqueo.',
        );
  }

  Future<void> liberarSlot({
    required String tokenBloqueo,
    required String barberoId,
    required DateTime fecha,
    required TimeOfDay horaInicio,
  }) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.slotsLiberar,
      data: {
        'tokenBloqueo': tokenBloqueo,
        'barberoId': barberoId,
        'fechaCita': fecha.toApiDate,
        'horaInicio': _formatTime(horaInicio),
      },
      fromJson: (json) => json,
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible liberar el horario bloqueado.'
            : response.message,
      );
    }
  }
}

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
