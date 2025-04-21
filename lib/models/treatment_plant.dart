import 'model.dart';

class TreatmentPlant extends Model {
  final int id;
  final String name;
  final int municipalityId;
  final String? address;
  final double? latitude;
  final double? longitude;

  TreatmentPlant({
    required this.id,
    required this.name,
    required this.municipalityId,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory TreatmentPlant.fromJson(Map<String, dynamic> json) {
    return TreatmentPlant(
      id: json['id'] as int,
      name: json['name'] as String,
      municipalityId: json['municipalityId'] as int,
      address: json['address'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'municipalityId': municipalityId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
} 