import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  static String get baseUrl => kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _storage.write(key: 'jwt_token', value: response.data['access_token']);
        await _storage.write(key: 'user_role', value: response.data['user']['role']);
        await _storage.write(key: 'user_name', value: response.data['user']['name']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> getUserInfo() async {
    final name = await _storage.read(key: 'user_name') ?? 'Usuario';
    final role = await _storage.read(key: 'user_role') ?? 'Ciudadano';
    return {'name': name, 'role': role};
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
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
}