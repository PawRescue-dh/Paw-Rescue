import 'package:flutter_test/flutter_test.dart';
import 'package:pawrescue/core/config.dart';
import 'package:pawrescue/services/auth_service.dart';

void main() {
  test('La URL del API es HTTPS por defecto (no localhost) y la usa AuthService',
      () {
    expect(AppConfig.apiUrl.startsWith('http'), isTrue);
    expect(AppConfig.apiUrl.contains('localhost'), isFalse);
    expect(AuthService.baseUrl, AppConfig.apiUrl);
  });

  test('Los timeouts permiten el arranque en frío de Render', () {
    expect(AppConfig.connectTimeout.inSeconds, greaterThanOrEqualTo(30));
  });
}
