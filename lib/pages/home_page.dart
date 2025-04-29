import 'package:flutter/material.dart';
import '../db/api.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // bool _sendStatistic = false;
  String _topHeader = 'Приветствуем Вас!';
  List<dynamic> _fastOrders = [];
  List<dynamic> _localOrders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (Api.user.id == 0) {
      try {
        await Api.fetchUserData(Api.user.id);
        setState(() {
          _topHeader = 'Приветствуем Вас, ${Api.user.firstName}!';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Что-то пошло не так')),
        );
      }
    } else {
      setState(() {
        _topHeader = 'Приветствуем Вас, ${Api.user.firstName}!';
      });
    }

    _updateOrders();
  }

  void _updateOrders() {
    setState(() {
      _localOrders = Api.attachedOrders.where((order) =>
          order.orderStatusId == OrderStatus.transport.id ||
          order.orderStatusId == OrderStatus.utilization.id).toList();
          
      _fastOrders = Api.attachedOrders.where((order) {
        final now = DateTime.now();
        return order.arrivalStartDate!.year == now.year &&
            order.arrivalStartDate!.month == now.month &&
            order.arrivalStartDate!.day == now.day &&
            (order.orderStatusId == OrderStatus.attached.id ||
                order.orderStatusId == OrderStatus.transport.id ||
                order.orderStatusId == OrderStatus.utilization.id);
      }).toList();
    });
  }

  Widget _buildFastOrdersRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24, bottom: 8),
          child: Text(
            'Заявки на сегодня',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          height: 130,
          padding: const EdgeInsets.only(left: 24, bottom: 42),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _fastOrders.isEmpty ? 1 : _fastOrders.length,
            itemBuilder: (context, index) {
              if (_fastOrders.isEmpty) {
                return const Center(child: Text('На сегодня нет заявок'));
              }
              return _buildOrderPreviewCard(_fastOrders[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderPreviewCard(dynamic order) {
    String timeRange = '';
    if (order.arrivalStartDate != null && order.arrivalEndDate != null) {
      final start = order.arrivalStartDate;
      final end = order.arrivalEndDate;
      final startStr = DateFormat('HH:mm').format(start);
      final endStr = DateFormat('HH:mm').format(end);
      timeRange = '$startStr - $endStr';
    }
    return Card(
      margin: const EdgeInsets.only(right: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _getStatusColor(order.orderStatusId),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Вывоз ЖБО',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: Text(
                    order.getPeriod(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    timeRange,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              ],
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                order.getStatusString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLine(String status) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          status,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int statusId) {
    // Здесь нужно определить цвета для разных статусов
    switch (statusId) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _topHeader,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const Text(
                      'Главная',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                ),
              ],
            ),
          ),
          _buildFastOrdersRow(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Текущий рейс',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _localOrders.isEmpty
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  Api.treatmentPlants.isEmpty
                                      ? '/route'
                                      : '/route_finish',
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE3F2FD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                        ),
                        child: Text(
                          'Завершить рейс',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.triecoBaseBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _localOrders.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDDF),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline),
                                const SizedBox(width: 12),
                                const Text(
                                  'Текущих заявок нет',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _localOrders.length,
                            itemBuilder: (context, index) {
                              final order = _localOrders[index];
                              return _buildOrderLine(order);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderLine(dynamic order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Заявка №${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Expanded(
                    child: SizedBox(
                      width: 200, // задайте нужную вам ширину
                      child: Text(
                        order.adress ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 10,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true, // явно разрешаем перенос
                      ),
                    ),
                  ),
                Text(
                  'Объем ${order.wasteVolume} m³',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum OrderStatus {
  new_(0),
  attached(1),
  transport(2),
  utilization(3),
  done(4),
  canceled(5);

  final int id;
  const OrderStatus(this.id);
} 