import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Cliente HTTP único: agrega el JWT guardado y traduce los errores a mensajes claros.
class ApiClient {
  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // Sin almacenamiento seguro (por ejemplo en pruebas): se envía sin token.
        }
        handler.next(options);
      },
    ));
  }

  static final ApiClient instance = ApiClient._();

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Ejecuta una llamada y convierte [DioException] en [ApiException].
  Future<T> run<T>(Future<T> Function(Dio dio) call) async {
    try {
      return await call(dio);
    } on DioException catch (e) {
      throw ApiException(_messageFrom(e), e.response?.statusCode);
    }
  }

  static String _messageFrom(DioException e) {
    final data = e.response?.data;
    final status = e.response?.statusCode;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      if (m is List) {
        return 'Revisa los datos ingresados.';
      }
      return m.toString();
    }
    if (status == 401) return 'Tu sesión expiró. Vuelve a iniciar sesión.';
    if (status == 403) return 'No tienes permiso para realizar esta acción.';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'El servidor tardó en responder. Intenta de nuevo en unos segundos.';
      case DioExceptionType.connectionError:
        return 'Sin conexión con el servidor. Revisa tu internet.';
      default:
        return 'Ocurrió un error inesperado (${status ?? 'sin respuesta'}).';
    }
  }
}
