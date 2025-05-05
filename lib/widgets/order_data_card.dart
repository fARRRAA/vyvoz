import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db/models/order.dart';
import '../pages/attached_orders.dart';

class OrderDataCard extends StatelessWidget {
  final Order order;
  final BuildContext navigation;
  final Widget Function() additionalContent;

  const OrderDataCard({
    Key? key,
    required this.order,
    required this.navigation,
    required this.additionalContent,
  }) : super(key: key);

  Future<void> _launchMap(double lat, double lng) async {
    final String url = "https://yandex.ru/maps/?rtext=~$lat%2C$lng";
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Заявка №${order.id}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            _buildRow("Статус", StatusLineColored(statusId: order.orderStatusId)),
            SizedBox(height: 8),
            _buildRow("Объем", Text("${order.wasteVolume} куб. метра", style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 8),
            _buildRow("Адрес", TextButton(
              onPressed: () => _launchMap(55.751244, 49.123244), // пример координат
              child: Text(order.adress ?? "", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            )),
            SizedBox(height: 8),
            _buildRow("Имя Фамилия", Text("${order.firstName ?? order.userFirstName} ${order.lastName ?? order.userLastName}", style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 8),
            _buildRow("Контактный телефон", Text(order.phoneNumber ?? order.userPhone, style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 8),
            _buildRow("Дата", Text(order.formattedDate, style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 8),
            _buildRow("Время вывоза", Text(order.getPeriod(), style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(height: 8),
            additionalContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text(label)),
        Expanded(child: value),
      ],
    );
  }
}