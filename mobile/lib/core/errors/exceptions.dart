/// Autores: AGUSTIN PARRA y CARLOS PALMA
/// 
/// Base class for all custom exceptions in the application.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

/// Thrown when there is a communication error (e.g., no internet).
class NetworkException extends AppException {
  const NetworkException([super.message = "Error de comunicación. Verifique su conexión."]);
}

/// Thrown when the server returns an unsuccessful response.
class ServerException extends AppException {
  const ServerException([super.message = "Error en el servidor. Intente más tarde."]);
}

/// Thrown when a request takes too long to complete.
class TimeoutException extends AppException {
  const TimeoutException([super.message = "Tiempo de espera agotado."]);
}

/// Thrown when there is an authentication error.
class AuthException extends AppException {
  const AuthException([super.message = "Error de autenticación. Verifique sus credenciales."]);
}
