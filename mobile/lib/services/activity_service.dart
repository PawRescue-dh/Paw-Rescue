import '../core/api_client.dart';
import '../models/models.dart';

class ActivityService {
  final ApiClient _api = ApiClient.instance;

  Future<List<ActivityItem>> list() async {
    final response = await _api.run((dio) => dio.get('/activity'));
    return (response.data as List)
        .map((e) => ActivityItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
