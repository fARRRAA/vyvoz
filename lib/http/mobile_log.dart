class MobileLog {
  final String message;
  final String level;

  MobileLog({
    required this.message,
    required this.level,
  });

  factory MobileLog.fromJson(Map<String, dynamic> json) {
    return MobileLog(
      message: json['message'] as String,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'level': level,
    };
  }
} 