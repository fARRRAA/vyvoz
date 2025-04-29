import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vyvoz/db/api.dart';

import '../db/models/order.dart';
// === Dummy Data & Models ===

class StatusLineColored extends StatelessWidget {
  final int statusId;

  const StatusLineColored({super.key, required this.statusId});

  // Маппинг ID статуса в название и цвет
  static const Map<int, String> stageToString = {
    1: "Назначено",
    2: "Транспортировка",
    3: "Утилизация",
    4: "Выполнено",
    5: "Отменено"
  };

  static const Map<int, Color> stageToColorId = {
    1: Colors.blue,
    2: Colors.purple,
    3: Colors.orange,
    4: Colors.green,
    5: Colors.red
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
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

enum OrderStatus {
  attached,
  transport,
  utilization,
  done,
  canceled;

  int get id => index + 1; // assuming 1-based indexing
}

Map<int, String> stageToString = {
  1: "Назначено",
  2: "Транспортировка",
  3: "Утилизация",
  4: "Выполнено",
  5: "Отменено"
};

Map<int, Color> stageToColorId = {
  1: Colors.blue,
  2: Colors.purple,
  3: Colors.orange,
  4: Colors.green,
  5: Colors.red
};
// === UI Part ===

class OrdersView extends StatefulWidget {
  const OrdersView({Key? key}) : super(key: key);

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  late List<Order> localOrders;
  late Function filter;
  late int selectedStatusId;
  late Color selectedColor = Colors.blue;
  late Color unselectedColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    selectedStatusId = -1;
    filter = (Order o) => o.orderStatusId != OrderStatus.done.id;
    refreshOrders();
  }

  void refreshOrders() {
    setState(() {
      localOrders = Api.attachedOrders
          .where(filter as bool Function(Order))
          .toList()
        ..sort((a, b) => b.timeOfPublication.compareTo(a.timeOfPublication));
    });
  }

  void onFilterSelected(int statusId) {
    setState(() {
      selectedStatusId = statusId;
      if (statusId == -1) {
        filter = (Order o) => o.orderStatusId != OrderStatus.done.id;
      } else {
        filter = (Order o) => o.orderStatusId == statusId;
      }
      refreshOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    onFilterSelected(-1);
                  },
                  child: Text(
                    "Все",
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedStatusId == -1
                          ? selectedColor
                          : unselectedColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const VerticalDivider(
                    width: 1, thickness: 1, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Статус:", style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (var status in OrderStatus.values)
                            ClickableStatusLineColored(
                              statusId: status.id,
                              onClick: () => onFilterSelected(status.id),
                              isSelected: selectedStatusId == status.id,
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: localOrders.length,
                itemBuilder: (context, index) {
                  var order = localOrders[index];
                  return OrderCard(order: order, onCardTap: (){
                    
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClickableStatusLineColored extends StatelessWidget {
  final int statusId;
  final VoidCallback onClick;
  final bool isSelected;

  const ClickableStatusLineColored({
    Key? key,
    required this.statusId,
    required this.onClick,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: stageToColorId[statusId] ?? Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          stageToString[statusId] ?? "—",
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onCardTap;

  const OrderCard({Key? key, required this.order, required this.onCardTap}) : super(key: key);

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
                    Icon(Icons.person, size: 20, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Вывоз ЖБО",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.map, color: Colors.blue),
                    onPressed: () async {
                      final String link =
                          "https://yandex.ru/maps/?rtext=~${order.latitude}%2C${order.longitude}";

                      await launchUrl(Uri.parse(link));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      order.adress ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Объем ${order.wasteVolume} м³",
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                "${order.arrivalStartDate.toString()}, ${order.getPeriod()}",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
