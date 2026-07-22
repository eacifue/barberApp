import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import 'models/admin_barberia_model.dart';
import 'models/admin_cliente_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(apiClientProvider));
});

class AdminRepository {
  const AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AdminBarberiaModel>> getBarberias() async {
    final response = await _apiClient.getList<List<AdminBarberiaModel>>(
      ApiEndpoints.adminBarberias,
      fromJson: (list) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(AdminBarberiaModel.fromJson)
            .toList();
      },
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible cargar barberías.'
            : response.message,
      );
    }

    return response.data ?? const [];
  }

  Future<AdminBarberiaModel> createBarberia(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.adminBarberias,
      data: payload,
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible crear barbería.'
            : response.message,
      );
    }

    return AdminBarberiaModel.fromJson(response.data!);
  }

  Future<AdminBarberiaModel> updateBarberia(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.adminBarberiaById(id),
      data: payload,
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible actualizar barbería.'
            : response.message,
      );
    }

    return AdminBarberiaModel.fromJson(response.data!);
  }

  Future<void> deleteBarberia(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.adminBarberiaById(id),
      fromJson: (json) => json,
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible eliminar barbería.'
            : response.message,
      );
    }
  }

  Future<List<AdminClienteModel>> getClientes() async {
    final response = await _apiClient.getList<List<AdminClienteModel>>(
      ApiEndpoints.adminClientes,
      fromJson: (list) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(AdminClienteModel.fromJson)
            .toList();
      },
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible cargar clientes.'
            : response.message,
      );
    }

    return response.data ?? const [];
  }

  Future<AdminClienteModel> createCliente({
    required String nombre,
    required String apellido,
    required String telefono,
    required String correo,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.adminClientes,
      data: {
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'correo': correo,
        'password': password,
      },
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible crear cliente.'
            : response.message,
      );
    }

    return AdminClienteModel.fromJson(response.data!);
  }

  Future<AdminClienteModel> updateCliente({
    required String id,
    required String nombre,
    required String apellido,
    required String telefono,
    required String correo,
    String? password,
    bool? activo,
  }) async {
    final payload = <String, dynamic>{
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'correo': correo,
    };

    final normalizedPassword = password?.trim();
    if ((normalizedPassword ?? '').isNotEmpty) {
      payload['password'] = normalizedPassword;
    }

    if (activo != null) {
      payload['activo'] = activo;
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.adminClienteById(id),
      data: payload,
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible actualizar cliente.'
            : response.message,
      );
    }

    return AdminClienteModel.fromJson(response.data!);
  }

  Future<void> deleteCliente(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.adminClienteById(id),
      fromJson: (json) => json,
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No fue posible desactivar cliente.'
            : response.message,
      );
    }
  }
}
