/// Configuración central de la app.
///
/// La URL del backend se define al compilar:
///   flutter build apk --release --dart-define=API_URL=https://TU-API.onrender.com
///   flutter run -d chrome --dart-define=API_URL=http://localhost:3000
class AppConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://paw-rescue-gmm8.onrender.com',
  );

  /// Render (plan gratuito) tarda en "despertar"; se da margen amplio.
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
