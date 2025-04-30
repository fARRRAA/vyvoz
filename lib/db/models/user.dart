import 'model.dart';
import '../http/user_update_request.dart';

class User extends Model {
  final int id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final int roleId;
  final String? companyName;
  final int? companyId;
  final int? municipalityId;
  final String? municipalityName;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
    required this.roleId,
    this.companyName,
    this.companyId,
    this.municipalityId,
    this.municipalityName,
  });

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    int? roleId,
    String? companyName,
    int? companyId,
    int? municipalityId,
    String? municipalityName,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      companyName: companyName ?? this.companyName,
      companyId: companyId ?? this.companyId,
      municipalityId: municipalityId ?? this.municipalityId,
      municipalityName: municipalityName ?? this.municipalityName,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      roleId: json['roleId'] as int,
      companyName: json['companyName'] as String?,
      companyId: json['companyId'] as int?,
      municipalityId: json['municipalityId'] as int?,
      municipalityName: json['municipalityName'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'roleId': roleId,
      'companyName': companyName,
      'companyId': companyId,
      'municipalityId': municipalityId,
      'municipalityName': municipalityName,
    };
  }

  UserUpdateRequest toUpdate() {
    return UserUpdateRequest(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );
  }
} 