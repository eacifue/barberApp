class BarbershopModel {
  const BarbershopModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.ciudad,
    required this.departamento,
    required this.pais,
    required this.activa,
    required this.activo,
    required this.horaApertura,
    required this.horaCierre,
    required this.diasDescanso,
  });

  final String id;
  final String nombre;
  final String direccion;
  final String ciudad;
  final String departamento;
  final String pais;
  final bool activa;
  final bool activo;

  /// "HH:mm:ss" opening/closing time, as configured by this barbershop.
  final String horaApertura;
  final String horaCierre;

  /// Spanish weekday names ("Lunes".."Domingo") this barbershop is closed,
  /// matching the backend's `DiaSemana` enum member names.
  final List<String> diasDescanso;

  static const _diasSemana = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo',
  ];

  /// Whether this barbershop is open on [date]'s weekday. Dart's
  /// [DateTime.weekday] (1=Monday..7=Sunday) lines up with the backend's
  /// `DiaSemana` enum (Lunes=1..Domingo=7), so the index maps directly.
  bool esDiaLaborable(DateTime date) {
    final nombre = _diasSemana[date.weekday - 1];
    return !diasDescanso.contains(nombre);
  }

  String get ubicacion => '$ciudad, $departamento · $pais';

  /// Full postal address for display and for building a maps deep link.
  /// Falls back to [ubicacion] when the backend hasn't set a street address.
  String get direccionCompleta =>
      direccion.trim().isEmpty ? ubicacion : '$direccion, $ciudad';

  bool get habilitada => activa && activo;

  factory BarbershopModel.fromJson(Map<String, dynamic> json) {
    return BarbershopModel(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? 'Barbería',
      direccion: json['direccion'] as String? ?? '',
      ciudad: json['ciudad'] as String? ?? 'Sin ciudad',
      departamento: json['departamento'] as String? ?? 'Sin estado',
      pais: json['pais'] as String? ?? 'Sin país',
      activa: json['activa'] as bool? ?? true,
      activo: json['activo'] as bool? ?? true,
      horaApertura: json['horaApertura'] as String? ?? '09:00:00',
      horaCierre: json['horaCierre'] as String? ?? '18:00:00',
      diasDescanso:
          (json['diasDescanso'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(),
    );
  }
}
