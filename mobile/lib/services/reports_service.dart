import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReportsService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
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
}