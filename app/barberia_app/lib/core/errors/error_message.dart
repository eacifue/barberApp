import 'package:dio/dio.dart';

import 'exceptions.dart';

/// Mensaje para mostrar al usuario: el del backend si viene en una
/// [AppException] (directa o envuelta por Dio), o [fallback] en otro caso.
String mensajeDeError(Object error, String fallback) {
  if (error is AppException && error.message.isNotEmpty) return error.message;
  if (error is DioException && error.error is AppException) {
    final message = (error.error as AppException).message;
    if (message.isNotEmpty) return message;
  }
  return fallback;
}

/// `true` si el backend rechazó la solicitud por validación (400/422), p. ej.
/// «ese horario ya no está disponible».
bool esErrorDeValidacion(Object error) =>
    error is ValidationException || (error is DioException && error.error is ValidationException);

/// La [AppException] detrás del error (directa o envuelta por Dio), si la hay.
AppException? excepcionDe(Object error) {
  if (error is AppException) return error;
  if (error is DioException && error.error is AppException) return error.error as AppException;
  return null;
}
