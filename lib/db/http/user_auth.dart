import '../models/user.dart';

class UserAuth {
  final String jwtToken;
  final String refreshToken;
  final int id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? phone;
  final String? email;
  final int roleId;
  final String? companyName;
  final int? companyId;
  final int? municipalityId;
  final String? municipalityName;
  final String? adress;
  UserAuth({
    required this.jwtToken,
    required this.refreshToken,
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.phone,
    this.email,
    required this.roleId,
    this.companyName,
    this.companyId,
    this.municipalityId,
    this.municipalityName,
    this.adress,
  });

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      jwtToken: json['jwtToken'] as String,
      refreshToken: json['refreshToken'] as String,
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      roleId: json['roleId'] as int,
      companyName: json['companyName'] as String?,
      companyId: json['companyId'] as int?,
      municipalityId: json['municipalityId'] as int?,
      municipalityName: json['municipalityName'] as String?,
      adress: json["adress"] as String?
    );
  }

  User toUser() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      roleId: roleId,
      companyName: companyName,
      companyId: companyId,
      municipalityId: municipalityId,
      municipalityName: municipalityName,
    );
  }
} 