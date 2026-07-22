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
      'latitud': 0,
      'longitud': 0,
      'horaApertura': '09:00:00',
      'horaCierre': '18:00:00',
      'diasDescanso': <String>[],
      'activa': activa,
    };
  }
}
