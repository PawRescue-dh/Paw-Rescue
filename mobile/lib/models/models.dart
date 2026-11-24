String _s(dynamic v, [String d = '']) => v == null ? d : v.toString();
String? _sn(dynamic v) => v == null ? null : v.toString();
DateTime? _d(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
double _n(dynamic v) => v is num ? v.toDouble() : double.tryParse(_s(v)) ?? 0;

class Pet {
  final String id;
  final String name;
  final String species;
  final String age;
  final String sex;
  final String size;
  final String description;
  final String health;
  final String? photoBase64;
  final String shelterName;
  final String shelterPhone;
  final String status;
  final String? adopterName;
  final String? adopterPhone;
  final String? adopterEmail;
  final DateTime? adoptedAt;
  final DateTime? createdAt;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.sex,
    required this.size,
    required this.description,
    required this.health,
    required this.photoBase64,
    required this.shelterName,
    required this.shelterPhone,
    required this.status,
    this.adopterName,
    this.adopterPhone,
    this.adopterEmail,
    this.adoptedAt,
    this.createdAt,
  });

  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
        id: _s(j['id']),
        name: _s(j['name'], 'Sin nombre'),
        species: _s(j['species'], 'Otro'),
        age: _s(j['age']),
        sex: _s(j['sex']),
        size: _s(j['size']),
        description: _s(j['description']),
        health: _s(j['health']),
        photoBase64: _sn(j['photoBase64']),
        shelterName: _s(j['shelterName'], 'Albergue'),
        shelterPhone: _s(j['shelterPhone']),
        status: _s(j['status'], 'Disponible'),
        adopterName: _sn(j['adopterName']),
        adopterPhone: _sn(j['adopterPhone']),
        adopterEmail: _sn(j['adopterEmail']),
        adoptedAt: _d(j['adoptedAt']),
        createdAt: _d(j['createdAt']),
      );
}

class AdoptionRequest {
  final String id;
  final String petId;
  final String citizenName;
  final String citizenEmail;
  final String citizenPhone;
  final String? message;
  final String status;
  final DateTime? createdAt;
  final Pet? pet;

  const AdoptionRequest({
    required this.id,
    required this.petId,
    required this.citizenName,
    required this.citizenEmail,
    required this.citizenPhone,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.pet,
  });

  factory AdoptionRequest.fromJson(Map<String, dynamic> j) {
    final petJson = j['pet'];
    return AdoptionRequest(
      id: _s(j['id']),
      petId: _s(j['petId']),
      citizenName: _s(j['citizenName']),
      citizenEmail: _s(j['citizenEmail']),
      citizenPhone: _s(j['citizenPhone']),
      message: _sn(j['message']),
      status: _s(j['status'], 'Pendiente'),
      createdAt: _d(j['createdAt']),
      pet: petJson is Map ? Pet.fromJson(Map<String, dynamic>.from(petJson)) : null,
    );
  }
}

class Report {
  final String id;
  final String species;
  final String urgency;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final String? reporterName;
  final String? photoBase64;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.species,
    required this.urgency,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.reporterName,
    required this.photoBase64,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> j) => Report(
        id: _s(j['id']),
        species: _s(j['species'], 'Otro'),
        urgency: _s(j['urgency'], 'Media'),
        description: _s(j['description']),
        latitude: _n(j['latitude']),
        longitude: _n(j['longitude']),
        status: _s(j['status'], 'Pendiente'),
        reporterName: _sn(j['reporterName']),
        photoBase64: _sn(j['photoBase64']),
        createdAt: _d(j['createdAt']),
      );
}

class ReportComment {
  final String id;
  final String authorName;
  final String authorRole;
  final String text;
  final DateTime? createdAt;

  const ReportComment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.text,
    required this.createdAt,
  });

  factory ReportComment.fromJson(Map<String, dynamic> j) => ReportComment(
        id: _s(j['id']),
        authorName: _s(j['authorName']),
        authorRole: _s(j['authorRole']),
        text: _s(j['text']),
        createdAt: _d(j['createdAt']),
      );
}

class ActivityItem {
  final String id;
  final String type;
  final String message;
  final String? actorName;
  final String? actorRole;
  final DateTime? createdAt;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.message,
    required this.actorName,
    required this.actorRole,
    required this.createdAt,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> j) => ActivityItem(
        id: _s(j['id']),
        type: _s(j['type']),
        message: _s(j['message']),
        actorName: _sn(j['actorName']),
        actorRole: _sn(j['actorRole']),
        createdAt: _d(j['createdAt']),
      );
}
