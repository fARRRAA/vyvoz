import 'model.dart';
import 'order_status.dart';

class Order extends Model {
  final int id;
  final int sewerId;
  final int? companyId;
  final int orderStatusId;
  final int wasteVolume;
  final String address;
  final String? comment;
  final DateTime arrivalStartDate;
  final DateTime? arrivalEndDate;
  final double latitude;
  final double longitude;
  final String municipalityName;
  final bool isPaid;
  final String? paymentLink;
  final String? paymentStatus;

  Order({
    required this.id,
    required this.sewerId,
    this.companyId,
    required this.orderStatusId,
    required this.wasteVolume,
    required this.address,
    this.comment,
    required this.arrivalStartDate,
    this.arrivalEndDate,
    required this.latitude,
    required this.longitude,
    required this.municipalityName,
    required this.isPaid,
    this.paymentLink,
    this.paymentStatus,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      sewerId: json['sewerId'] as int,
      companyId: json['companyId'] as int?,
      orderStatusId: json['orderStatusId'] as int,
      wasteVolume: json['wasteVolume'] as int,
      address: json['address'] as String,
      comment: json['comment'] as String?,
      arrivalStartDate: DateTime.parse(json['arrivalStartDate'] as String),
      arrivalEndDate: json['arrivalEndDate'] != null
          ? DateTime.parse(json['arrivalEndDate'] as String)
          : null,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      municipalityName: json['municipalityName'] as String,
      isPaid: json['isPaid'] as bool,
      paymentLink: json['paymentLink'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sewerId': sewerId,
      'companyId': companyId,
      'orderStatusId': orderStatusId,
      'wasteVolume': wasteVolume,
      'address': address,
      'comment': comment,
      'arrivalStartDate': arrivalStartDate.toIso8601String(),
      'arrivalEndDate': arrivalEndDate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'municipalityName': municipalityName,
      'isPaid': isPaid,
      'paymentLink': paymentLink,
      'paymentStatus': paymentStatus,
    };
  }
} 