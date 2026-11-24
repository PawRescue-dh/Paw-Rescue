import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../core/config.dart';

/// Datos de la sesión iniciada.
class UserSession {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;

  const UserSession({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
  });

  bool get isShelter => role == 'Albergue';
  bool get isCitizen => role == 'Ciudadano';
}

class AuthService {
  // La URL se configura con --dart-define=API_URL=... (ver lib/core/config.dart)
  static const String baseUrl = AppConfig.apiUrl;

  final ApiClient _api = ApiClient.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserSession> login(String email, String password) async {
    final response = await _api.run((dio) => dio.post('/auth/login', data: {
          'email': email,
          'password': password,
        }));
    return _saveSession(response.data);
  }

  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
    required bool acceptedPrivacy,
  }) async {
    final response = await _api.run((dio) => dio.post('/auth/register', data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phone': phone,
          'acceptedPrivacy': acceptedPrivacy,
        }));
    return _saveSession(response.data);
  }

  Future<UserSession> _saveSession(dynamic data) async {
    final user = Map<String, dynamic>.from(data['user'] as Map);
    await _storage.write(key: 'jwt_token', value: data['access_token'].toString());
    await _storage.write(key: 'user_id', value: user['id'].toString());
    await _storage.write(key: 'user_name', value: user['name'].toString());
    await _storage.write(key: 'user_email', value: user['email'].toString());
    await _storage.write(key: 'user_role', value: user['role'].toString());
    await _storage.write(key: 'user_phone', value: (user['phone'] ?? '').toString());
    return UserSession(
      id: user['id'].toString(),
      name: user['name'].toString(),
      email: user['email'].toString(),
      role: user['role'].toString(),
      phone: user['phone']?.toString(),
    );
  }

  /// Sesión guardada en el dispositivo, o null si no hay.
  Future<UserSession?> currentUser() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final role = await _storage.read(key: 'user_role');
      if (token == null || token.isEmpty || role == null) return null;
      final phone = await _storage.read(key: 'user_phone');
      return UserSession(
        id: await _storage.read(key: 'user_id') ?? '',
        name: await _storage.read(key: 'user_name') ?? 'Usuario',
        email: await _storage.read(key: 'user_email') ?? '',
        role: role,
        phone: (phone == null || phone.isEmpty) ? null : phone,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.deleteAll();
    } catch (_) {
      // Nada que borrar.
    }
  }
}
