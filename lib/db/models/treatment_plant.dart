import 'model.dart';

class TreatmentPlant extends Model {
  final int id;
  final String? adress;
  final String name;
  final double? latitude;
  final double? longitude;
  final double tariff=200;
  final int? dailyLimit;
  TreatmentPlant({
    required this.id,
    required this.name,
    this.adress,
    this.latitude,
    this.dailyLimit,
    this.longitude,
  });

  factory TreatmentPlant.fromJson(Map<String, dynamic> json) {
    return TreatmentPlant(
      id: json['id'] as int,
      name: json['name'] as String,
      adress: json['adress'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      dailyLimit: json['dailyLimit'] as int
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'adress': adress,
      'latitude': latitude,
      'dailyLimit':dailyLimit,
      'longitude': longitude,
    };
  }
} 