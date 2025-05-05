import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vyvoz/db/api.dart';
import 'package:vyvoz/db/models/order.dart';
import 'package:vyvoz/db/models/treatment_plant.dart';
import 'package:vyvoz/utils/constants.dart';

class RouteFinishPage extends StatefulWidget {
  const RouteFinishPage({Key? key}) : super(key: key);

  @override
  _RouteFinishPageState createState() => _RouteFinishPageState();
}

class _RouteFinishPageState extends State<RouteFinishPage> {
  TreatmentPlant? _plant;
  List<Order> _orders = [];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _plant = ModalRoute.of(context)!.settings.arguments as TreatmentPlant;
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _orders = Api.attachedOrders
          .where(
              (order) => order.orderStatusId == 2 || order.orderStatusId == 3)
          .toList();
    });
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Ошибка получения местоположения: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Завершение рейса'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Информация о заказах
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Информация о заказах',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildOrdersInfo(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Карточка с информацией о сливной станции
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Сливная станция',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const Divider(),
                    Text(
                      _plant?.name ?? "Не выбрана",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Адрес',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _plant?.adress ?? "Адрес не указан",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (_plant?.latitude != null &&
                            _plant?.longitude != null)
                          IconButton(
                            icon: const Icon(Icons.map, color: Colors.blue),
                            onPressed: () => _openRoute(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 16),

            // Список заказов
            Expanded(
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return _buildOrderCard(order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersInfo() {
    final orderIds = _orders.map((order) => order.id.toString()).join(', ');
    final totalVolume =
        _orders.fold(0, (sum, order) => sum + order.wasteVolume);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Заказы: $orderIds',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Общий объем: $totalVolume м³',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          OrderQRCode(orderIds: _orders.map((o){ return o.id; }).toList())
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Заявка №${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(
                  width: 130,
                  child: Text('Статус'),
                ),
                _buildStatusChip(order.orderStatusId),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(
                  width: 130,
                  child: Text('Объем'),
                ),
                Text(
                  '${order.wasteVolume} куб. метра',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
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
    );
  }

  void _openRoute() async {
    if (_currentPosition == null ||
        _plant?.latitude == null ||
        _plant?.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Невозможно построить маршрут из-за отсутствия координат')),
      );
      return;
    }

    final url =
        'https://yandex.ru/maps/?mode=routes&rtext=${_currentPosition!.latitude},${_currentPosition!.longitude}~${_plant!.latitude},${_plant!.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Невозможно открыть карту')),
      );
    }
  }
}

class OrderQRCode extends StatelessWidget {
  final List<int> orderIds;

  const OrderQRCode({
    super.key,
    required this.orderIds,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Предъявите QR-код при въезде на территорию очистных сооружений",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            QrImageView(
              data: "$orderIds",
              // Аналог JSON.encodeToString(orderIds)
              version: QrVersions.auto,
              size: 175,
              gapless: true,
              errorCorrectionLevel: QrErrorCorrectLevel.L,
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
