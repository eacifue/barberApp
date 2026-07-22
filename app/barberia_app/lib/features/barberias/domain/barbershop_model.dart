class BarbershopModel {
  const BarbershopModel({
    required this.id,
    required this.nombre,
    required this.ciudad,
    required this.departamento,
    required this.pais,
    required this.activa,
    required this.activo,
  });

  final String id;
  final String nombre;
  final String ciudad;
  final String departamento;
  final String pais;
  final bool activa;
  final bool activo;

  String get ubicacion => '$ciudad, $departamento · $pais';

  bool get habilitada => activa && activo;

  factory BarbershopModel.fromJson(Map<String, dynamic> json) {
    return BarbershopModel(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? 'Barbería',
      ciudad: json['ciudad'] as String? ?? 'Sin ciudad',
      departamento: json['departamento'] as String? ?? 'Sin estado',
      pais: json['pais'] as String? ?? 'Sin país',
      activa: json['activa'] as bool? ?? true,
      activo: json['activo'] as bool? ?? true,
    );
  }
}
