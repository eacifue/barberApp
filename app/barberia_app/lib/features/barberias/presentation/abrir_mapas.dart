import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:url_launcher/url_launcher.dart';

import '../domain/barbershop_model.dart';

/// Abre la app de mapas en la barbería (Apple Maps en iOS, Google Maps en el resto).
/// Devuelve `false` si no se pudo abrir.
Future<bool> abrirMapas(BarbershopModel barbershop) {
  final query = Uri.encodeComponent('${barbershop.nombre}, ${barbershop.direccionCompleta}');
  final apple = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;
  final uri = apple ? Uri.parse('https://maps.apple.com/?q=$query') : Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
