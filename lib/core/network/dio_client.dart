import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cliente HTTP centralizado con manejo de errores, tiempo de espera e interceptores.
class DioClient {
  late Dio dio;

  DioClient() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.sebastian.cl/vote';

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('[REQUEST] ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('[RESPONSE] ${response.statusCode} ${response.statusMessage}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('[ERROR] ${e.type} - ${e.message}');
        final message = _mapErrorToMessage(e);
        return handler.reject(
          DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: message,
            message: message,
          ),
        );
      },
    ));
  }

  String _mapErrorToMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de espera agotado. Intenta nuevamente.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Sin conexión a internet. Verifica tu red.';
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Solicitud incorrecta. Revisa los parámetros enviados.';
        case 401:
          return 'No autorizado. Debes iniciar sesión nuevamente.';
        case 403:
          return 'Acceso denegado. No tienes permisos para esta acción.';
        case 404:
          return 'No se encontró el recurso solicitado.';
        case 408:
          return 'Tiempo de espera agotado por el servidor.';
        case 500:
          return 'Error interno del servidor. Intenta más tarde.';
        case 503:
          return 'Servicio no disponible. El servidor no responde.';
        default:
          return 'Error inesperado (${statusCode}). Intenta más tarde.';
      }
    }

    return 'Error desconocido. Verifica tu conexión o inténtalo nuevamente.';
  }
}
