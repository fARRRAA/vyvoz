class SendPositionCommand {
  final double latitude;
  final double longitude;
  final int orderId;

  SendPositionCommand({
    required this.latitude,
    required this.longitude,
    required this.orderId,
  });

  factory SendPositionCommand.fromJson(Map<String, dynamic> json) {
    return SendPositionCommand(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      orderId: json['orderId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'orderId': orderId,
    };
  }
} 