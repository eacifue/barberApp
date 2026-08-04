import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/admin_repository.dart';
import '../../data/models/admin_cliente_model.dart';

final adminClientesProvider = FutureProvider.autoDispose<List<AdminClienteModel>>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).getClientes();
});
