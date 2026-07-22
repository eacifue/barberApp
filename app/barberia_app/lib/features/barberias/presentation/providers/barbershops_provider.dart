import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/barbershop_repository.dart';
import '../../domain/barbershop_model.dart';

final barbershopsProvider = FutureProvider<List<BarbershopModel>>((ref) async {
  final repository = ref.watch(barbershopRepositoryProvider);
  return repository.getBarbershops();
});
