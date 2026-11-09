import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../barberias/presentation/providers/barberia_elegida_provider.dart';

/// La barbería que se administra: la elegida en el dispositivo. Para el
/// administrador de barbería coincide con la de su cuenta (entró con ella); el
/// SuperAdmin opera la que eligió.
final adminBarberiaIdProvider = FutureProvider<String?>((ref) async {
  return (await ref.watch(barberiaElegidaProvider.future))?.id;
});
