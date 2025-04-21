import 'model.dart';

class OrderCreationData extends Model {
  final String municipalityName;
  final int wasteVolume;
  final String address;
  final String? comment;
  final DateTime timestamp;
  final double longitude;
  final double latitude;

  OrderCreationData({
    required this.municipalityName,
    required this.wasteVolume,
    required this.address,
    this.comment,
    required this.timestamp,
    required this.longitude,
    required this.latitude,
  });

  factory OrderCreationData.fromJson(Map<String, dynamic> json) {
    return OrderCreationData(
      municipalityName: json['municipalityName'] as String,
      wasteVolume: json['wasteVolume'] as int,
      address: json['address'] as String,
      comment: json['comment'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'municipalityName': municipalityName,
      'wasteVolume': wasteVolume,
      'address': address,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'longitude': longitude,
      'latitude': latitude,
    };
  }
} 