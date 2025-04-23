import 'model.dart';

class Sewer extends Model {
  final int id;
  final String name;
  final int userId;
  final int companyId;
  final String? phoneNumber;
  final String? email;

  Sewer({
    required this.id,
    required this.name,
    required this.companyId,
    required this.userId,
    this.phoneNumber,
    this.email,
  });

  factory Sewer.fromJson(Map<String, dynamic> json) {
    return Sewer(
      id: json['id'] as int,
      name: json['sewerCarModel'] as String,
      userId: json['userId'] as int,
      companyId: json["companyId"] as int,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'companyId': companyId,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
} 