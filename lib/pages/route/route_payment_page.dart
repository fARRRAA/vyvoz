import 'package:flutter/material.dart';
import 'package:vyvoz/db/api.dart';
import 'package:vyvoz/db/models/treatment_plant.dart';
import 'package:vyvoz/db/models/order.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class RoutePaymentPage extends StatefulWidget {
  const RoutePaymentPage({Key? key}) : super(key: key);

  @override
  _RoutePaymentPageState createState() => _RoutePaymentPageState();
}

class _RoutePaymentPageState extends State<RoutePaymentPage> {
  bool _showBanner = true;
  bool _isGotoPay = false;
  String _paymentLink = "";
  bool _isLoading = true;
  List<Order> _notPayedOrders = [];
  TreatmentPlant? _plant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _plant = ModalRoute.of(context)!.settings.arguments as TreatmentPlant;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Получаем список неоплаченных заказов
      _notPayedOrders = Api.attachedOrders
          .where((order) => 
              (order.orderStatusId == 2 || order.orderStatusId == 3) && 
              !order.isPayed)
          .toList();

      if (_notPayedOrders.isEmpty) {
        Navigator.pushReplacementNamed(
          context, 
          '/route_finish',
          arguments: _plant,
        );
        return;
      }

      // Вычисляем сумму для оплаты
      final totalVolume = _notPayedOrders.fold(
        0, (sum, order) => sum + order.wasteVolume);
      
      // TODO: Проверить тариф, в исходном классе TreatmentPlant есть поле tariff,
      // но в нашей модели отсутствует. Пока используем захардкоженное значение.
      final tariff = 320.0;
      final totalSum = totalVolume * tariff;
      
      // Формируем строку с номерами заказов
      final orderIds = _notPayedOrders.map((o) => "№ ${o.id}").join(", ");
      
      // Получаем ссылку для оплаты
      _paymentLink = await Api.getPaymentLink(
        totalSum,
        "Оплата заказов $orderIds",
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Завершение рейса'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isGotoPay) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Оплата'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isGotoPay = false;
              });
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Переход на страницу оплаты..."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (await canLaunch(_paymentLink)) {
                    await launch(_paymentLink, 
                      universalLinksOnly: false,
                      forceSafariVC: false,
                      forceWebView: false,
                    );
                    
                    // Предположим успешную оплату для демонстрации
                    await _markOrdersAsPaid();
                    
                    Navigator.pushReplacementNamed(
                      context,
                      '/route_finish',
                      arguments: _plant,
                    );
                  } else {
                    setState(() {
                      _isGotoPay = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Невозможно открыть страницу оплаты'),
                      ),
                    );
                  }
                },
                child: const Text('Открыть страницу оплаты'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Для демонстрации механизма без фактической оплаты
                  _markOrdersAsPaid();
                  Navigator.pushReplacementNamed(
                    context,
                    '/route_finish',
                    arguments: _plant,
                  );
                },
                child: const Text('Симуляция успешной оплаты (только для демо)'),
              ),
            ],
          ),
        ),
      );
    }

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
            if (_showBanner) _buildPaymentBanner(),
            Expanded(
              child: ListView.builder(
                itemCount: _notPayedOrders.length,
                itemBuilder: (context, index) {
                  final order = _notPayedOrders[index];
                  return _buildOrderCard(order);
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isGotoPay = true;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Оплатить', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBanner() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFFFFEDDF).withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(
              child: const Text(
                'Данная функция служит для создания заявки на утилизацию, в случае если запрос на вывоз ЖБО поступил не через систему Trieco',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showBanner = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const Icon(Icons.assignment),
            const SizedBox(width: 10),
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
                  Text(
                    order.adress ?? "",
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markOrdersAsPaid() async {
    for (var order in _notPayedOrders) {
      await Api.setOrderPaid(order.id);
    }
  }
} 