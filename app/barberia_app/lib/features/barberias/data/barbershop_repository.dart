import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../domain/barbershop_model.dart';

final barbershopRepositoryProvider = Provider<BarbershopRepository>((ref) {
  return BarbershopRepository(ref.watch(apiClientProvider));
});

class BarbershopRepository {
  const BarbershopRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BarbershopModel>> getBarbershops() async {
    final response = await _apiClient.getList<List<BarbershopModel>>(
      ApiEndpoints.barberias,
      extra: ApiClient.sinBarberia,
      fromJson: (list) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(BarbershopModel.fromJson)
            .where((barbershop) => barbershop.habilitada)
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
}
