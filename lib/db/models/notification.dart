import 'model.dart';

class Notification extends Model {
  final String message;
  final String type;

  Notification({
    required this.message,
    required this.type,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      message: json['message'] as String,
      type: json['type'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type,
    };
  }
} 