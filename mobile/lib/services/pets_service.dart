import '../core/api_client.dart';
import '../models/models.dart';

class PetsService {
  final ApiClient _api = ApiClient.instance;

  List<Pet> _pets(dynamic data) => (data as List)
      .map((e) => Pet.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  List<AdoptionRequest> _requests(dynamic data) => (data as List)
      .map((e) => AdoptionRequest.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  /// Tablero: solo mascotas disponibles.
  Future<List<Pet>> listAvailable() async {
    final response = await _api.run((dio) => dio.get('/pets'));
    return _pets(response.data);
  }

  /// Albergue: todas las mascotas, con datos del adoptante.
  Future<List<Pet>> listAll() async {
    final response = await _api.run((dio) => dio.get('/pets/manage/all'));
    return _pets(response.data);
  }

  Future<Pet> getPet(String id) async {
    final response = await _api.run((dio) => dio.get('/pets/$id'));
    return Pet.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> createPet({
    required String name,
    required String species,
    required String age,
    required String sex,
    required String size,
    required String description,
    required String health,
    String? shelterPhone,
    String? photoBase64,
  }) async {
    await _api.run((dio) => dio.post('/pets', data: {
          'name': name,
          'species': species,
          'age': age,
          'sex': sex,
          'size': size,
          'description': description,
          'health': health,
          if (shelterPhone != null && shelterPhone.isNotEmpty) 'shelterPhone': shelterPhone,
          if (photoBase64 != null && photoBase64.isNotEmpty) 'photoBase64': photoBase64,
        }));
  }

  Future<void> adopt(String petId, String phone, String? message) async {
    await _api.run((dio) => dio.post('/pets/$petId/adopt', data: {
          'phone': phone,
          if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
        }));
  }

  Future<List<AdoptionRequest>> myRequests() async {
    final response = await _api.run((dio) => dio.get('/pets/requests/mine'));
    return _requests(response.data);
  }

  Future<List<AdoptionRequest>> allRequests() async {
    final response = await _api.run((dio) => dio.get('/pets/requests/all'));
    return _requests(response.data);
  }

  Future<void> decide(String requestId, String status) async {
    await _api.run((dio) => dio.patch('/pets/requests/$requestId', data: {'status': status}));
  }
}
