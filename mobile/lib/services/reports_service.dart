import '../core/api_client.dart';
import '../models/models.dart';

class ReportsService {
  final ApiClient _api = ApiClient.instance;

  Future<void> createReport({
    required String species,
    required String urgency,
    required String description,
    required double latitude,
    required double longitude,
    String? photoBase64,
  }) async {
    await _api.run((dio) => dio.post('/reports', data: {
          'species': species,
          'urgency': urgency,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'photoBase64': photoBase64 ?? '',
        }));
  }

  /// Albergue: todos los reportes. Ciudadano: solo los suyos. Sin fotos.
  Future<List<Report>> getReports() async {
    final response = await _api.run((dio) => dio.get('/reports'));
    return (response.data as List)
        .map((e) => Report.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Detalle completo (incluye la foto).
  Future<Report> getReportById(String id) async {
    final response = await _api.run((dio) => dio.get('/reports/$id'));
    return Report.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> updateStatus(String id, String status) async {
    await _api.run((dio) => dio.patch('/reports/$id/status', data: {'status': status}));
  }

  Future<List<ReportComment>> getComments(String id) async {
    final response = await _api.run((dio) => dio.get('/reports/$id/comments'));
    return (response.data as List)
        .map((e) => ReportComment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addComment(String id, String text) async {
    await _api.run((dio) => dio.post('/reports/$id/comments', data: {'text': text}));
  }
}
