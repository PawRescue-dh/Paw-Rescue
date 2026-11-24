import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config.dart';

class ReportsService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> createReport({
    required String species,
    required String urgency,
    required String description,
    required double latitude,
    required double longitude,
    String? photoBase64,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await _dio.post(
        '/reports',
        data: {
          'species': species,
          'urgency': urgency,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'photoBase64': photoBase64 ?? '',
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getReports() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await _dio.get(
        '/reports',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Detalle completo (incluye la foto). El listado no la trae para ser ligero.
  Future<Map<String, dynamic>?> getReportById(String id) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await _dio.get(
        '/reports/$id',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Solo el rol Albergue puede cambiar el estado (el backend responde 403 si no).
  Future<bool> updateStatus(String id, String status) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await _dio.patch(
        '/reports/$id/status',
        data: {'status': status},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
