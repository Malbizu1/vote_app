import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  late Dio dio;
  final _auth = FirebaseAuth.instance;

  DioClient() {
    final baseUrl = (dotenv.env['API_BASE_URL'] ?? 'https://api.sebastian.cl/vote').replaceAll(RegExp(r'/+$'), '');

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = _auth.currentUser;
        if (user != null) {
          final idToken = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $idToken';
        }
        if (options.path.isNotEmpty && !options.path.startsWith('/')) {
          options.path = '/${options.path}';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final user = _auth.currentUser;
          if (user != null && (e.requestOptions.extra['retried401'] != true)) {
            try {
              final fresh = await user.getIdToken(true);
              final req = e.requestOptions;
              req.headers['Authorization'] = 'Bearer $fresh';
              req.extra['retried401'] = true;
              final clone = await dio.fetch(req);
              return handler.resolve(clone);
            } catch (_) {/* sigue abajo */}
          }
        }

        final msg = _mapError(e);
        return handler.reject(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          message: msg,
          error: msg,
        ));
      },
    ));
  }

  String _mapError(DioException e) {
    final sc = e.response?.statusCode;
    if (sc != null) {
      switch (sc) {
        case 400: return 'Solicitud incorrecta (400).';
        case 401: return 'No autorizado. Debes iniciar sesión.';
        case 403: return 'Acceso denegado (403).';
        case 404: return 'No se encontró el recurso.';
        case 408: return 'Tiempo de espera agotado (408).';
        case 500: return 'Error interno del servidor.';
        case 503: return 'Servicio no disponible.';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de espera agotado. Intenta nuevamente.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Sin conexión a internet.';
    }
    return e.message ?? 'Error desconocido.';
  }
}
