import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/admin_repository.dart';
import '../../data/models/admin_barberia_model.dart';

final adminBarberiasProvider = FutureProvider.autoDispose<List<AdminBarberiaModel>>((
  ref,
) {
  return ref.watch(adminRepositoryProvider).getBarberias();
});
