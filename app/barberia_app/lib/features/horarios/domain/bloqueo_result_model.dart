class BloqueoResultModel {
  const BloqueoResultModel({
    required this.exitoso,
    this.tokenBloqueo,
    this.expiresInSeconds,
    this.mensajeError,
  });

  final bool exitoso;
  final String? tokenBloqueo;
  final int? expiresInSeconds;
  final String? mensajeError;

  factory BloqueoResultModel.fromJson(Map<String, dynamic> json) {
    return BloqueoResultModel(
      exitoso: json['exitoso'] as bool? ?? false,
      tokenBloqueo: json['tokenBloqueo'] as String?,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt(),
      mensajeError: json['mensajeError'] as String?,
    );
  }
}
