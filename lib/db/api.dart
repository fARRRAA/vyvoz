import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'http/address_suggest.dart';
import 'http/mobile_log.dart';
import 'http/token_pair.dart';
import 'http/total_address_suggest.dart';
import 'http/user_auth.dart';
import 'models/order.dart';
import 'models/order_status.dart';
import 'models/sewer.dart';
import 'models/treatment_plant.dart';
import 'models/user.dart';

class Api {
  static late SharedPreferences preferences;
  static List<Order> attachedOrders = [];
  static List<Order> freeOrders = [];
  static late User user;
  static List<TreatmentPlant> treatmentPlants = [];
  static late Sewer sewer;

  static const String REST_API_PATH = 'http://95.105.78.72:8080/api/';
  static const String REFRESH = 'refresh';
  static const String TOKEN_START = 'start';
  static const int JWT_LIFETIME = 60 * 60;
  static const int REFRESH_LIFETIME = 60 * 60 * 24 * 30;

  static String currentJWT = '';

  static int get currentWasteVolume {
    return attachedOrders
        .where((order) =>
            order.orderStatusId == OrderStatus.transport.id ||
            order.orderStatusId == OrderStatus.utilization.id)
        .fold(0, (sum, order) => sum + order.wasteVolume);
  }

  static Future<void> saveAuthorization(String jwt, String refresh) async {
    currentJWT = jwt;
    await preferences.setString(REFRESH, refresh);
    await preferences.setInt(TOKEN_START,
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
  }

  static bool isReloginRequested() {
    final start = preferences.getInt(TOKEN_START) ?? 0;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return start + REFRESH_LIFETIME < now;
  }

  static Future<void> tryUpdateAuth() async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final tokensStart = preferences.getInt(TOKEN_START) ?? 0;

    if (tokensStart + JWT_LIFETIME > now && currentJWT.isNotEmpty) return;

    if (tokensStart + REFRESH_LIFETIME < now) {
      onReauth();
    }

    final refresh = preferences.getString(REFRESH) ?? '';
    final response = await http.get(
      Uri.parse('${REST_API_PATH}Users/RefreshAuthorization?refreshToken=$refresh'),
    );

    if (response.statusCode == 200) {
      final tokens = TokenPair.fromJson(jsonDecode(response.body));
      await saveAuthorization(tokens.jwtToken, tokens.refreshToken);
    }
  }

  static Future<void> fetchSewerCollection() async {
    await tryUpdateAuth();
    final url = '${REST_API_PATH}Order/collection?SewerId=${sewer.id}';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $currentJWT'},
    );

    if (response.statusCode == 200) {
      final collection = (jsonDecode(response.body) as List)
          .map((json) => Order.fromJson(json))
          .toList();

      attachedOrders = collection
          .where((order) =>
              order.sewerId == sewer.id &&
              order.orderStatusId != OrderStatus.canceled.id)
          .toList();

      freeOrders = collection
          .where((order) => order.orderStatusId == OrderStatus.new_)
          .toList();
    } else {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }
  }

  static Future<User> authorize(String login, String password) async {
    final url =
        '${REST_API_PATH}Users/Authorization?Username=$login&Password=$password';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final auth = UserAuth.fromJson(jsonDecode(response.body));
      await saveAuthorization(auth.jwtToken, auth.refreshToken);
      user = auth.toUser();
    } else {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }
    return user;
  }

  static Future<void> fetchUserData(int id) async {
    await tryUpdateAuth();
    final url = '${REST_API_PATH}Users/GetUserById?Id=$id';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $currentJWT'},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }

    user = User.fromJson(jsonDecode(response.body));
  }

  static Future<Sewer> getSewerById([int? userId]) async {
    await tryUpdateAuth();
    final id = userId ?? user.id;
    final url = '${REST_API_PATH}Sewers/GetSeverByUserId?UserId=$id';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $currentJWT'},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }

    return Sewer.fromJson(jsonDecode(response.body));
  }

  static Future<Order> getOrderById(int id) async {
    await tryUpdateAuth();
    final url = '${REST_API_PATH}Order/OrdersById?Id=$id';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $currentJWT'},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }

    return Order.fromJson(jsonDecode(response.body));
  }

  static Future<void> setOrderStatus(int orderId, int statusId) async {
    await tryUpdateAuth();
    final url = '${REST_API_PATH}Order/ChangeOrderStatus?OrderId=$orderId';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentJWT',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'orderId': orderId,
        'orderStatusId': statusId,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }
  }

  static Future<void> attachOrder(
      int orderId, int sewerId, int companyId) async {
    await tryUpdateAuth();
    var url = '${REST_API_PATH}Order/AttachSewer?OrderId=$orderId';
    var response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentJWT',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'sewerId': sewerId}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }

    url = '${REST_API_PATH}Order/AttachCompany?OrderId=$orderId';
    response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentJWT',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'companyId': companyId}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }
  }

  static Future<http.Response> confirmOrder(String code) async {
    await tryUpdateAuth();
    final url =
        '${REST_API_PATH}Order/confirm?Code=$code&OrderStatusId=3';
    return await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $currentJWT'},
    );
  }

  static Future<http.Response> updateUser() async {
    await tryUpdateAuth();
    final url = '${REST_API_PATH}Users/UpdateUser?id=${user.id}';
    return await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentJWT',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toUpdate()),
    );
  }

  static Future<List<TreatmentPlant>> getPlants(int municipalityId) async {
    await tryUpdateAuth();
    final url =
        '${REST_API_PATH}Plants/municipality?MunicipalityId=$municipalityId';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $currentJWT'},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }

    treatmentPlants = (jsonDecode(response.body) as List)
        .map((json) => TreatmentPlant.fromJson(json))
        .toList();
    return treatmentPlants;
  }

  static Future<void> createOrder({
    required String municipalityName,
    required int wasteVolume,
    required String address,
    required String comment,
    required DateTime timestamp,
    required double longitude,
    required double latitude,
  }) async {
    await tryUpdateAuth();
    final body = {
      'comment': comment,
      'wasteVolume': wasteVolume,
      'adress': address,
      'sewerId': user.id,
      'arrivalStartDate': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'municipalityName': municipalityName,
    };

    final url = '${REST_API_PATH}Order/self';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentJWT',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }

    final orderId = jsonDecode(response.body)['id'];
    final order = await getOrderById(orderId);
    freeOrders.remove(order);
    attachedOrders.add(order);
    attachedOrders = attachedOrders.toSet().toList();
    refreshOrders();
  }

  static Future<List<TreatmentPlant>> getPlantsForSewer() async {
    await tryUpdateAuth();
    final url = '${REST_API_PATH}Plants/sewers?SewerId=${sewer.id}';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $currentJWT'},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }

    return (jsonDecode(response.body) as List)
        .map((json) => TreatmentPlant.fromJson(json))
        .toList();
  }

  static Future<String> getPaymentLink(
      double summ, String orderName) async {
    await tryUpdateAuth();
    final url = '${REST_API_PATH}Billing/invoice/link';
    final body = {
      'userId': user.id,
      'payAmount': summ,
      'orderName': orderName,
      'serviceName': 'Оплата Триэко',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentJWT',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }

    return jsonDecode(response.body)['link'];
  }

  static Future<String> getInvoiceStatus(String invoiceId) async {
    await tryUpdateAuth();
    final url =
        '${REST_API_PATH}Billing/invoice/status?InvoiceId=$invoiceId';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $currentJWT'},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }

    return jsonDecode(response.body)['status'];
  }

  static Future<void> setOrderPaid(int orderId) async {
    await tryUpdateAuth();
    final url = '${REST_API_PATH}Order/paid?OrderId=$orderId';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentJWT',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        response.body,
        url,
        response.statusCode.toString(),
      );
    }
  }

  static Future<List<AddressSuggest>> getAddresses(String prompt) async {
    try {
      final url =
          'https://maps.vk.com/api/suggest?api_key=RSe0266ce5cca3990591009afbbecaf35c12e6ec656e4a7682eae76b617f3745&q=${!prompt.toLowerCase().contains('россия') ? 'Россия ' : ''}$prompt&lang=ru&fields=address';
      final response = await http.get(Uri.parse(url));
      final parsed = TotalAddressSuggest.fromJson(jsonDecode(response.body));
      return parsed.results;
    } catch (e) {
      return [];
    }
  }

  static Future<void> sendLog(MobileLog log) async {
    if (currentJWT.isEmpty) return;
    await tryUpdateAuth();
    final url = '${REST_API_PATH}Logging';
    await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $currentJWT',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(log.toJson()),
    );
  }

  static void onReauth() {}

  static void refreshOrders() {}
}

class ApiException implements Exception {
  final String message;
  final String url;
  final String code;

  ApiException(this.message, this.url, this.code);

  @override
  String toString() {
    return 'Error code ($code) in api by request $url\nMessage: $message';
  }
}

class JsonParseException implements Exception {
  final String text;
  final String url;
  final String message;

  JsonParseException(this.text, this.url, this.message);

  @override
  String toString() {
    return 'Parse error of $text in api by request $url';
  }
} 