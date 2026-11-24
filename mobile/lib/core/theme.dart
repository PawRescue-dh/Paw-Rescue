import 'package:flutter/material.dart';

/// Paleta inspirada en el diseño de PawRescue (azul, amarillo y fondo crema).
class AppColors {
  static const Color blue = Color(0xFF1E6FD9);
  static const Color blueDark = Color(0xFF1555B0);
  static const Color blueLight = Color(0xFFE3F0FF);
  static const Color yellow = Color(0xFFFFD25A);
  static const Color yellowDark = Color(0xFFF5B82E);
  static const Color orange = Color(0xFFF5A623);
  static const Color cream = Color(0xFFFDF8F3);
  static const Color pink = Color(0xFFF8D7E0);
  static const Color peach = Color(0xFFFFE2C7);
  static const Color mint = Color(0xFFD6F0E8);
  static const Color text = Color(0xFF1F2A44);
  static const Color muted = Color(0xFF6B7690);
  static const Color line = Color(0xFFE2E8F2);
  static const Color success = Color(0xFF2E9E6B);
  static const Color danger = Color(0xFFD64545);
  static const Color warning = Color(0xFFF08C2E);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    primary: AppColors.blue,
    secondary: AppColors.yellow,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: true,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

Color urgencyColor(String urgency) {
  switch (urgency) {
    case 'Crítica':
      return const Color(0xFF8E1B1B);
    case 'Alta':
      return AppColors.danger;
    case 'Media':
      return AppColors.warning;
    case 'Baja':
    default:
      return AppColors.success;
  }
}

Color reportStatusColor(String status) {
  switch (status) {
    case 'Resuelto':
      return AppColors.success;
    case 'En atención':
      return AppColors.blue;
    case 'Pendiente':
    default:
      return AppColors.warning;
  }
}

Color petStatusColor(String status) {
  switch (status) {
    case 'Adoptada':
      return AppColors.success;
    case 'Reservada':
      return AppColors.blue;
    case 'Disponible':
    default:
      return AppColors.orange;
  }
}

Color requestStatusColor(String status) {
  switch (status) {
    case 'Aprobada':
      return AppColors.success;
    case 'Rechazada':
      return AppColors.danger;
    case 'Pendiente':
    default:
      return AppColors.warning;
  }
}
