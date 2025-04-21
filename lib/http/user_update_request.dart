class UserUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phone;
  final String? email;

  UserUpdateRequest({
    this.firstName,
    this.lastName,
    this.middleName,
    this.phone,
    this.email,
  });

  factory UserUpdateRequest.fromJson(Map<String, dynamic> json) {
    return UserUpdateRequest(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      middleName: json['middleName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (middleName != null) data['middleName'] = middleName;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    return data;
  }
} 