import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config.dart';

class AuthService {
  // La URL se configura con --dart-define=API_URL=... (ver lib/core/config.dart)
  static const String baseUrl = AppConfig.apiUrl;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
  ));
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

  Future<bool> register(String name, String email, String password, String role) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
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
}