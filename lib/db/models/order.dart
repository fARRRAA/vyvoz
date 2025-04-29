import 'package:intl/intl.dart';

import 'model.dart';

class Order extends Model {
  final int id;
  final int? sewerId;
  final int orderStatusId;
  final int wasteVolume;
  final String? adress;
  final String? comment;
  final DateTime? arrivalStartDate;
  final DateTime? arrivalEndDate;
  final double latitude;
  final double longitude;
  final int? municipalityId;
  final bool isPayed;
  final DateTime timeOfPublication;
  final bool selfCreated;
  Order({
    required this.id,
    required this.sewerId,
    required this.orderStatusId,
    required this.wasteVolume,
    required this.adress,
    this.comment,
    required this.arrivalStartDate,
    this.arrivalEndDate,
    required this.latitude,
    required this.longitude,
    required this.municipalityId,
    required this.isPayed,
    required this.timeOfPublication,
    required this.selfCreated
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      sewerId: json['sewerId'] as int?,
      orderStatusId: json['orderStatusId'] as int,
      wasteVolume: json['wasteVolume'] as int,
      adress: json['adress'] as String?,
      comment: json['comment'] as String?,
      arrivalStartDate: DateTime.parse(json['arrivalStartDate'] as String),
      arrivalEndDate: json['arrivalEndDate'] != null
          ? DateTime.parse(json['arrivalEndDate'] as String)
          : null,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      municipalityId: json['municipalityId'] as int?,
      isPayed: json['isPayed'] as bool,
        timeOfPublication: DateTime.parse(json["timeOfPublication"] as String),
      selfCreated: json["selfCreated"] as bool,
    );
  }

  String getPeriod() {
    return "${DateFormat('d MMMM yyyy').format(arrivalStartDate!)}";
  }
String getStartTime(){

    return "${DateFormat('HH:mm').format(arrivalStartDate!)}";
}
String getEndTime(){

    return "${DateFormat('HH:mm').format(arrivalEndDate!)}";
}
  static Map<int, String> statuses = {
    1: "Новый заказ",
    2: "Транспортировка",
    3: "Утилизация",
    4: "Завершенный",
    5: "Отмененный",
    6: "Принятый"
  };

  String getStatusString() {
    return statuses[orderStatusId]!;
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sewerId': sewerId,
      'orderStatusId': orderStatusId,
      'wasteVolume': wasteVolume,
      'adress': adress,
      'comment': comment,
      'arrivalStartDate': arrivalStartDate?.toIso8601String(),
      'arrivalEndDate': arrivalEndDate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'municipalityId': municipalityId,
      'isPayed': isPayed,
      'selfCreated': selfCreated
    };
  }
}
