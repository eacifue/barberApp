class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/auth/login';
  static const String registro = '/auth/registro';
  static const String authFcmToken = '/auth/fcm-token';
  static const String authLogout = '/auth/logout';

  static const String adminBarberias = '/admin/barberias';
  static const String adminClientes = '/admin/clientes';
  static const String barberias = '/barberias';

  static String adminBarberiaById(String id) => '/admin/barberias/$id';
  static String adminClienteById(String id) => '/admin/clientes/$id';

  static const String servicios = '/servicios';
  static const String barberos = '/barberos';
  static const String citas = '/citas';
  static const String slotsBloquear = '/slots/bloquear';
  static const String slotsLiberar = '/slots/liberar';

  static String servicioPorId(String id) => '/servicios/$id';

  static String barberoPorId(String id) => '/barberos/$id';

  static String serviciosPorBarberia(String barberiaId) =>
      '/barberias/$barberiaId/servicios';

  static String barberosPorBarberia(String barberiaId) =>
      '/barberias/$barberiaId/barberos';

  static String barberosPorServicio(String servicioId) =>
      '/servicios/$servicioId/barberos';

  static String disponibilidadBarbero(String barberoId) =>
      '/barberos/$barberoId/disponibilidad';

  static String citasPorBarbero(String barberoId) =>
      '/barberos/$barberoId/citas';

  static String citaPorId(String citaId) => '/citas/$citaId';

  static String cancelarCita(String citaId) => '/citas/$citaId/cancelar';
}
