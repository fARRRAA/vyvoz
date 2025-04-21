import 'model.dart';

class Sewer extends Model {
  final int id;
  final String name;
  final int userId;
  final String? phone;
  final String? email;

  Sewer({
    required this.id,
    required this.name,
    required this.userId,
    this.phone,
    this.email,
  });

  factory Sewer.fromJson(Map<String, dynamic> json) {
    return Sewer(
      id: json['id'] as int,
      name: json['name'] as String,
      userId: json['userId'] as int,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'phone': phone,
      'email': email,
    };
  }
} 