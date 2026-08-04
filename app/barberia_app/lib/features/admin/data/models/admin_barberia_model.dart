class AdminBarberiaModel {
  const AdminBarberiaModel({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.direccion,
    required this.ciudad,
    required this.departamento,
    required this.activa,
    required this.activo,
    required this.horaApertura,
    required this.horaCierre,
    required this.diasDescanso,
    required this.latitud,
    required this.longitud,
  });

  final String id;
  final String nombre;
  final String telefono;
  final String correo;
  final String direccion;
  final String ciudad;
  final String departamento;
  final bool activa;
  final bool activo;
  final String horaApertura;
  final String horaCierre;
  final List<String> diasDescanso;
  final double latitud;
  final double longitud;

  factory AdminBarberiaModel.fromJson(Map<String, dynamic> json) {
    return AdminBarberiaModel(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      ciudad: json['ciudad'] as String? ?? '',
      departamento: json['departamento'] as String? ?? '',
      activa: json['activa'] as bool? ?? true,
      activo: json['activo'] as bool? ?? true,
      horaApertura: json['horaApertura'] as String? ?? '09:00:00',
      horaCierre: json['horaCierre'] as String? ?? '18:00:00',
      diasDescanso:
          (json['diasDescanso'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toUpsertJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'direccion': direccion,
      'ciudad': ciudad,
      'departamento': departamento,
      'latitud': latitud,
      'longitud': longitud,
      'horaApertura': horaApertura,
      'horaCierre': horaCierre,
      'diasDescanso': diasDescanso,
      'activa': activa,
    };
  }
}
