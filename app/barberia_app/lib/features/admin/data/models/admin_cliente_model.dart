class AdminClienteModel {
  const AdminClienteModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.correo,
    required this.rol,
    required this.activo,
  });

  final String id;
  final String nombre;
  final String apellido;
  final String telefono;
  final String correo;
  final String rol;
  final bool activo;

  String get nombreCompleto => ('$nombre $apellido').trim();

  factory AdminClienteModel.fromJson(Map<String, dynamic> json) {
    return AdminClienteModel(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      rol: json['rol'] as String? ?? '',
      activo: json['activo'] as bool? ?? true,
    );
  }
}
