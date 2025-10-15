import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }

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
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Solicitud incorrecta.';
        case 401:
          return 'No autorizado. Debes iniciar sesión.';
        case 403:
          return 'Acceso denegado.';
        case 404:
          return 'Recurso no encontrado.';
        case 500:
          return 'Error interno del servidor.';
      }
    }
    return 'Error de conexión o inesperado.';
  }
}
