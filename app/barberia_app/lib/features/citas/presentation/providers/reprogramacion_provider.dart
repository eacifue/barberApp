import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the id of the appointment being replaced by the "Reprogramar"
/// shortcut, so [ConfirmacionScreen] knows to cancel the old appointment
/// once the new one is successfully created. Null outside of that flow.
final citaIdAReprogramarProvider = StateProvider<String?>((ref) => null);
