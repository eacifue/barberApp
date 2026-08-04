import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/barbershop_repository.dart';
import '../../domain/barbershop_model.dart';

final barbershopsProvider = FutureProvider<List<BarbershopModel>>((ref) async {
  final repository = ref.watch(barbershopRepositoryProvider);
  return repository.getBarbershops();
});

/// The single barbershop this app is configured for. The app only ever
/// serves one business, so this resolves to the first (and only) result
/// instead of asking the user to pick one.
final myBarbershopProvider = FutureProvider<BarbershopModel?>((ref) async {
  final barbershops = await ref.watch(barbershopsProvider.future);
  return barbershops.isEmpty ? null : barbershops.first;
});
