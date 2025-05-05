import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vyvoz/db/api.dart';
import 'package:vyvoz/db/models/order.dart';

import 'order_page.dart';

class FreeOrdersPage extends StatefulWidget {
  const FreeOrdersPage({super.key});

  @override
  State<FreeOrdersPage> createState() => _FreeOrdersPageState();
}

class _FreeOrdersPageState extends State<FreeOrdersPage> {
  List<Order> localOrders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
    Api.onRefreshOrders = _loadOrders;
  }

  void _loadOrders() {
    setState(() {
      localOrders = Api.freeOrders.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 44, 24, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: ListView.builder(
                itemCount: localOrders.length,
                itemBuilder: (context, index) {
                  final order = localOrders[index];
                  return OrderCard(
                    order: order,
                    onCardTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderPage(
                            orderId: order.id,
                            isProof: false,
                            isFreeOrder: true,
                          ),
                        ),
                      ).then((_) => _loadOrders());
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onCardTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onCardTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusLineColored(statusId: order.orderStatusId),
                  const Spacer(),
                  if (order.selfCreated)
                    const Icon(Icons.person, size: 20, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Вывоз ЖБО",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () async {
                      final String link =
                          "https://yandex.ru/maps/?rtext=~${order.latitude}%2C${order.longitude}";
                      await launchUrl(Uri.parse(link));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      order.adress ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Объем ${order.wasteVolume} м³",
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                "${order.getPeriod()}, ${order.getStartTime()}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusLineColored extends StatelessWidget {
  final int statusId;

  const StatusLineColored({super.key, required this.statusId});

  static const Map<int, String> stageToString = {
    1: "Новый заказ",
    2: "Транспортировка",
    3: "Утилизация",
    4: "Выполнено",
    5: "Отменено",
    6: "Принята"
  };

  static const Map<int, Color> stageToColorId = {
    1: Colors.blue,
    2: Colors.purple,
    3: Colors.orange,
    4: Colors.lightGreen,
    5: Colors.red,
    6: Colors.green
  };

  @override
  Widget build(BuildContext context) {
    final text = stageToString[statusId] ?? "Неизвестно";
    final color = stageToColorId[statusId] ?? Colors.grey;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}