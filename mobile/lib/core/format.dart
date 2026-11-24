String _two(int n) => n.toString().padLeft(2, '0');

/// 24/11/2026 14:30
String formatDateTime(DateTime? d) {
  if (d == null) return '';
  final l = d.toLocal();
  return '${_two(l.day)}/${_two(l.month)}/${l.year} ${_two(l.hour)}:${_two(l.minute)}';
}

/// "hace 5 min", "hace 2 h", "hace 3 d"
String timeAgo(DateTime? d) {
  if (d == null) return '';
  final diff = DateTime.now().difference(d.toLocal());
  if (diff.inSeconds < 60) return 'justo ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  if (diff.inDays < 30) return 'hace ${diff.inDays} d';
  return formatDateTime(d);
}

bool isValidEmail(String v) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

/// Teléfono de 10 a 15 dígitos (admite +, espacios y guiones).
bool isValidPhone(String v) {
  final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length >= 10 &&
      digits.length <= 15 &&
      RegExp(r'^[0-9+\s-]{10,20}$').hasMatch(v.trim());
}
