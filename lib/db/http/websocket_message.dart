class WebsocketMessage {
  final String type;
  final Map<String, dynamic> data;

  WebsocketMessage({
    required this.type,
    required this.data,
  });

  factory WebsocketMessage.fromJson(Map<String, dynamic> json) {
    return WebsocketMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
    };
  }
} 