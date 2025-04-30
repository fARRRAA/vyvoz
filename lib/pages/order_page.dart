import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../db/api.dart';
import '../db/models/order.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  final int orderId;
  final bool isProof;
  final bool isFreeOrder;

  const OrderPage({
    Key? key,
    required this.orderId,
    this.isProof = false,
    this.isFreeOrder = false,
  }) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Order? order;
  bool isLoading = true;
  String? confirmationCode;
  bool isConfirmationEnabled = true;
  final TextEditingController _confirmationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    try {
      final loadedOrder = await Api.getOrderById(widget.orderId);
      setState(() {
        order = loadedOrder;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при загрузке заказа')),
        );
      }
    }
  }

  Future<void> _handleOrderAction() async {
    if (order == null) return;

    try {
      if (widget.isFreeOrder || order!.orderStatusId == 1) {
        await Api.attachOrder(order!.id, Api.sewer.id, Api.sewer.companyId);
        await _loadOrder();
      } else if (order!.orderStatusId == 6) {
        await Api.setOrderStatus(order!.id, 2); // Транспортировка
        await _loadOrder();
      }

      await Api.fetchSewerCollection();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при обработке заказа')),
        );
      }
    }
  }

  Future<void> _cancelOrder() async {
    if (order == null) return;

    try {
      await Api.setOrderStatus(order!.id, 5); // Отменен
      await _loadOrder(); // Перезагружаем заказ
      await Api.fetchSewerCollection();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при отмене заказа')),
        );
      }
    }
  }

  String _getButtonText() {
    if (widget.isProof) return 'Подтвердить заявку';
    if (widget.isFreeOrder) return 'Принять заказ';

    switch (order?.orderStatusId) {
      case 1:
        return 'Принять';
      case 6:
        return 'Выехал на заявку';
      default:
        return '';
    }
  }

  Future<void> _handleConfirmationCode(String code) async {
    if (code.length != 4) return;

    setState(() {
      isConfirmationEnabled = false;
    });

    try {
      final response = await Api.confirmOrder(code);
      if (response.statusCode == 200) {
        await _loadOrder(); // Перезагружаем заказ
        await Api.fetchSewerCollection();
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Неправильный код подтверждения')),
          );
          setState(() {
            isConfirmationEnabled = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при подтверждении заказа')),
        );
        setState(() {
          isConfirmationEnabled = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Заказ не найден'),
        ),
        body: const Center(
          child: Text('Информация о заказе недоступна'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Карточка заявки',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Заявка №${order!.id}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoSection('Статус', _buildStatusBadge()),
                _buildInfoSection(
                    'Объем',
                    Text(
                      '${order!.wasteVolume} куб. метра',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                _buildInfoSection(
                    'Адрес',
                    GestureDetector(
                      onTap: () {
                        final url =
                            'https://yandex.ru/maps/?rtext=~${order!.latitude}%2C${order!.longitude}';
                        launchUrl(Uri.parse(url));
                      },
                      child: Text(
                        order!.adress ?? 'Не указан',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    )),
                _buildInfoSection(
                    'Дата',
                    Text(
                      order!.getPeriod(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                _buildInfoSection(
                    'Время вывоза',
                    Text(
                      '${order!.getStartTime()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                if (order!.orderStatusId == 2) ...[
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'Код подтверждения',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _confirmationController,
                          enabled: isConfirmationEnabled,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          onChanged: _handleConfirmationCode,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                if (_getButtonText().isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleOrderAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _getButtonText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                if (!widget.isFreeOrder && order!.orderStatusId != 5) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _cancelOrder,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Отменить заказ',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;

    switch (order!.orderStatusId) {
      case 1:
        statusColor = Colors.blue;
        statusText = "Непринятый";
        break;
      case 2:
        statusColor = Colors.purple;
        statusText = "Транспортировка";
        break;
      case 3:
        statusColor = Colors.orange;
        statusText = "Утилизация";
        break;
      case 4:
        statusColor = Colors.green;
        statusText = "Выполнено";
        break;
      case 5:
        statusColor = Colors.red;
        statusText = "Отменено";
        break;
      case 6:
        statusColor = Colors.green;
        statusText = "Принята";
        break;
      default:
        statusColor = Colors.grey;
        statusText = "Неизвестно";
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          statusText,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String reasonText = '';

        return AlertDialog(
          title: const Text('Причина отмены заявки'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Напишите причину отмены заявки'),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => reasonText = value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Причина отмены',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelOrder();
              },
              child: const Text('Отправить'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: label=="Статус"?80:140,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
