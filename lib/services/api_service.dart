import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'YOUR_API_BASE_URL';
  static late User user;
  static late Sewer sewer;

  Future<void> fetchUserData(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/Users/$userId'));
    if (response.statusCode == 200) {
      user = User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<Sewer> getSewerById() async {
    final response = await http.get(Uri.parse('$baseUrl/Sewers/${user.id}'));
    if (response.statusCode == 200) {
      sewer = Sewer.fromJson(json.decode(response.body));
      return sewer;
    } else {
      throw Exception('Failed to load sewer data');
    }
  }
}

class User {
  final int id;
  final int roleId;

  User({required this.id, required this.roleId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      roleId: json['roleId'],
    );
  }
}

class Sewer {
  final int id;
  final int companyId;

  Sewer({required this.id, required this.companyId});

  factory Sewer.fromJson(Map<String, dynamic> json) {
    return Sewer(
      id: json['id'],
      companyId: json['companyId'],
    );
  }
}