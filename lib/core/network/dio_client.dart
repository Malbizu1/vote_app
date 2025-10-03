import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.sebastian.cl/vote';

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 🚨 Aquí luego añadiremos Authorization: Bearer <idToken>
        return handler.next(options);
      },
      onError: (e, handler) {
        print("Error en petición: ${e.response?.statusCode}");
        return handler.next(e);
      },
    ));
  }
}
