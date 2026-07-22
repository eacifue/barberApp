class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  final bool success;
  final String message;
  final T? data;
  final List<String> errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: rawData is Map<String, dynamic> ? fromJson(rawData) : null,
      errors: (json['errors'] as List<dynamic>? ?? const [])
          .map((error) => error.toString())
          .toList(),
    );
  }

  factory ApiResponse.fromJsonList(
    Map<String, dynamic> json,
    T Function(List<dynamic>) fromJson,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: rawData is List<dynamic> ? fromJson(rawData) : null,
      errors: (json['errors'] as List<dynamic>? ?? const [])
          .map((error) => error.toString())
          .toList(),
    );
  }
}
