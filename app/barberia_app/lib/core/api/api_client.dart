import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../config/router.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';
import 'api_response.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    ref: ref,
    secureStorageService: ref.watch(secureStorageProvider),
  );
});

class ApiClient {
  /// Va en cada petición. `X-Barberia-Id`: la barbería de esta app; el API la usa en
  /// login, registro y catálogo (con sesión manda el token). El selector llega después.
  static const encabezadosBase = <String, String>{
    'Content-Type': 'application/json',
    'X-Barberia-Id': AppConfig.defaultBarberiaId,
  };

  ApiClient({
    required Ref ref,
    required SecureStorageService secureStorageService,
  }) : _ref = ref,
       _secureStorageService = secureStorageService,
       _dio = Dio(
         BaseOptions(
           baseUrl: AppConfig.baseUrl,
           connectTimeout: AppConfig.connectTimeout,
           receiveTimeout: AppConfig.receiveTimeout,
           headers: encabezadosBase,
         ),
       ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            await _secureStorageService.clearToken();
            final router = _ref.read(routerProvider);
            router.go('/login');
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: UnauthorizedException(
                  'Tu sesión expiró. Inicia sesión nuevamente.',
                ),
              ),
            );
            return;
          }

          final responseData = error.response?.data;
          final message = responseData is Map<String, dynamic>
              ? (responseData['message'] as String? ??
                    'Ocurrió un error inesperado.')
              : 'Ocurrió un error inesperado.';

          switch (statusCode) {
            case 400:
            case 422:
              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: ValidationException(message),
                ),
              );
              return;
            case 404:
              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: NotFoundException(message),
                ),
              );
              return;
            case 500:
              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: ServerException(message),
                ),
              );
              return;
            case 403:
              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: ForbiddenException(
                    message.isEmpty
                        ? 'No tienes permisos para acceder a este recurso.'
                        : message,
                  ),
                ),
              );
              return;
            default:
              if (error.type == DioExceptionType.connectionError ||
                  error.type == DioExceptionType.connectionTimeout ||
                  error.type == DioExceptionType.receiveTimeout ||
                  error.type == DioExceptionType.sendTimeout) {
                handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: AppException(
                      'No se pudo conectar con el servidor. Verifica backend y red.',
                    ),
                  ),
                );
                return;
              }

              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: AppException(message),
                ),
              );
              return;
          }
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          compact: true,
        ),
      );
    }
  }

  final Ref _ref;
  final Dio _dio;
  final SecureStorageService _secureStorageService;

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: queryParams,
    );
    return ApiResponse<T>.fromJson(response.data ?? const {}, fromJson);
  }

  Future<ApiResponse<T>> getList<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    required T Function(List<dynamic>) fromJson,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: queryParams,
    );
    return ApiResponse<T>.fromJsonList(response.data ?? const {}, fromJson);
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return ApiResponse<T>.fromJson(response.data ?? const {}, fromJson);
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return ApiResponse<T>.fromJson(response.data ?? const {}, fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return ApiResponse<T>.fromJson(response.data ?? const {}, fromJson);
  }
}
