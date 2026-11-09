import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../barberos/domain/barbero_model.dart';

final adminBarberoRepositoryProvider = Provider<AdminBarberoRepository>((ref) {
  return AdminBarberoRepository(ref.watch(apiClientProvider));
});

class AdminBarberoRepository {
  const AdminBarberoRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Con [incluirInactivos] también llegan los desactivados (solo admin).
  Future<List<BarberoModel>> getBarberosPorBarberia(String barberiaId, {bool incluirInactivos = false}) async {
    final response = await _apiClient.getList<List<BarberoModel>>(
      ApiEndpoints.barberosPorBarberia(barberiaId),
      queryParams: incluirInactivos ? const {'incluirInactivos': true} : null,
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
            ? 'No fue posible cargar barberos.'
            : response.message,
      );
    }

    return response.data ?? const [];
  }

  Future<BarberoModel> createBarbero({
    required String nombre,
    required String apellido,
    required String telefono,
    required String correo,
    required String biografia,
    required int aniosExperiencia,
    required List<String> especialidades,
    required List<String> servicioIds,
    String? fotoUrl,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.barberos,
      data: {
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'correo': correo,
        'fotoUrl': fotoUrl,
        'biografia': biografia,
        'aniosExperiencia': aniosExperiencia,
        'especialidades': especialidades,
        'servicioIds': servicioIds,
      },
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible crear barbero.'
            : response.message,
      );
    }

    return BarberoModel.fromJson(response.data!);
  }

  Future<BarberoModel> updateBarbero({
    required String id,
    required String nombre,
    required String apellido,
    required String telefono,
    required String correo,
    required String biografia,
    required int aniosExperiencia,
    required List<String> especialidades,
    required List<String> servicioIds,
    String? fotoUrl,
  }) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.barberoPorId(id),
      data: {
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'correo': correo,
        'fotoUrl': fotoUrl,
        'biografia': biografia,
        'aniosExperiencia': aniosExperiencia,
        'especialidades': especialidades,
        'servicioIds': servicioIds,
      },
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible actualizar barbero.'
            : response.message,
      );
    }

    return BarberoModel.fromJson(response.data!);
  }

  Future<void> deleteBarbero(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.barberoPorId(id),
      fromJson: (json) => json,
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible eliminar barbero.'
            : response.message,
      );
    }
  }

  /// Reactiva un barbero desactivado.
  Future<BarberoModel> activarBarbero(String id) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiEndpoints.barberoPorId(id)}/activar',
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty ? 'No fue posible activar el barbero.' : response.message,
      );
    }

    return BarberoModel.fromJson(response.data!);
  }
}
