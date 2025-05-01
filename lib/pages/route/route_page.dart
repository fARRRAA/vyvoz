import 'package:flutter/material.dart';
import 'package:vyvoz/db/api.dart';
import 'package:vyvoz/db/models/order.dart';
import 'package:vyvoz/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  @override
  Widget build(BuildContext context) {
    final orders = Api.attachedOrders.where((order) =>
        order.orderStatusId == 2 || // transport
        order.orderStatusId == 3).toList(); // utilization

    return Scaffold(
      appBar: AppBar(
        title: const Text('Завершение рейса'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/treatment_plants_selector');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppColors.triecoBaseBlue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Выбрать сливную станцию', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Заявка №${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (order.adress != null)
                        Text(
                          order.adress!,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildInfoRow('Статус', _buildStatusChip(order.orderStatusId)),
            const SizedBox(height: 12),
            _buildInfoRow('Объем', Text('${order.wasteVolume} куб. метра', style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            _buildInfoRow('Адрес', Text(order.adress ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 12),
            if (order.comment != null)
              _buildInfoRow('Имя Фамилия', Text(order.comment ?? 'Иван Иванов', style: const TextStyle(fontWeight: FontWeight.w500))),
            if (order.comment != null)
              const SizedBox(height: 12),
            _buildInfoRow('Контактный телефон', const Text('+79962866100', style: TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 12),
            _buildInfoRow('Дата', Text(_formatDate(order.arrivalStartDate), style: const TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 12),
            _buildInfoRow('Время вывоза', Text('${_formatTime(order.arrivalStartDate)} - ${_formatTime(order.arrivalEndDate)}', style: const TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 16),
            if (order.latitude != 0 && order.longitude != 0)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map, color: Colors.blue),
                  label: const Text('Открыть на карте', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    _openMap(order.latitude, order.longitude);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: value),
      ],
    );
  }

  Widget _buildStatusChip(int statusId) {
    Color color;
    String text;

    switch (statusId) {
      case 2: // transportation
        color = Colors.blue;
        text = "Транспортировка";
        break;
      case 3: // utilization
        color = Colors.orange;
        text = "Утилизация";
        break;
      default:
        color = Colors.grey;
        text = "Неизвестный статус";
    }

    return Chip(
      backgroundColor: color.withOpacity(0.2),
      label: Text(text, style: TextStyle(color: color)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('HH:mm').format(date);
  }

  void _openMap(double lat, double lng) async {
    final url = 'https://yandex.ru/maps/?pt=$lng,$lat&z=17&l=map';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
} 