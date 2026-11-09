class AppConfig {
  AppConfig._();

  static const String env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5001/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static bool get isDebug => env != 'production';
}
