import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
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
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}