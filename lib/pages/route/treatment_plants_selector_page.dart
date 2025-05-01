import 'package:flutter/material.dart';
import 'package:vyvoz/db/api.dart';
import 'package:vyvoz/db/models/treatment_plant.dart';
import 'package:vyvoz/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class TreatmentPlantsSelectorPage extends StatefulWidget {
  const TreatmentPlantsSelectorPage({Key? key}) : super(key: key);

  @override
  _TreatmentPlantsSelectorPageState createState() => _TreatmentPlantsSelectorPageState();
}

class _TreatmentPlantsSelectorPageState extends State<TreatmentPlantsSelectorPage> {
  List<TreatmentPlant> _plants = [];
  bool _isLoading = true;
  int _selectedPlantIndex = -1;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _getCurrentLocation();
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

  Future<void> _loadPlants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Находим все текущие заказы
      final currentOrders = Api.attachedOrders.where((order) =>
        order.orderStatusId == 2 || order.orderStatusId == 3).toList();
      
      if (currentOrders.isEmpty) {
        throw Exception('Нет текущих заказов');
      }

      // Получаем уникальные муниципалитеты из заказов
      final municipalityIds = currentOrders
          .where((order) => order.municipalityId != null)
          .map((order) => order.municipalityId!)
          .toSet()
          .toList();
      
      if (municipalityIds.isEmpty) {
        throw Exception('У заказов отсутствуют муниципалитеты');
      }
      
      int bestMunicipalityId = municipalityIds.first;
      List<TreatmentPlant> bestPlants = [];
      
      for (final municipalityId in municipalityIds) {
        try {
          final plants = await Api.getPlants(municipalityId);
          
          if (plants.length > bestPlants.length) {
            bestMunicipalityId = municipalityId;
            bestPlants = plants;
          }
        } catch (e) {
          print('Ошибка при запросе станций для муниципалитета $municipalityId: $e');
        }
      }
      
      if (bestPlants.isEmpty) {
        throw Exception('Не найдено ни одной сливной станции для всех муниципалитетов');
      }

      print('Выбран муниципалитет $bestMunicipalityId с ${bestPlants.length} станциями');
      
      setState(() {
        _plants = bestPlants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки сливных станций: $e')),
      );
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
            ElevatedButton(
              onPressed: _selectedPlantIndex == -1 ? null : () {
                // Проверяем, оплачены ли все заказы
                final allOrders = Api.attachedOrders.where((order) =>
                  order.orderStatusId == 2 || order.orderStatusId == 3).toList();
                
                bool allPaid = true;
                for (var order in allOrders) {
                  if (!order.isPayed) {
                    allPaid = false;
                    break;
                  }
                }

                if (allPaid) {
                  Navigator.pushNamed(context, '/route_finish', arguments: _plants[_selectedPlantIndex]);
                } else {
                  Navigator.pushNamed(context, '/route_payment', arguments: _plants[_selectedPlantIndex]);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedPlantIndex == -1
                    ? Colors.grey
                    : AppColors.triecoBaseBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Выехал на утилизацию',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_plants.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Нет доступных сливных станций'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _plants.length,
                  itemBuilder: (context, index) {
                    final plant = _plants[index];
                    final isSelected = _selectedPlantIndex == index;
                    
                    return _buildPlantCard(
                      plant,
                      index + 1,
                      isSelected,
                      () {
                        setState(() {
                          _selectedPlantIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard(TreatmentPlant plant, int number, bool isSelected, VoidCallback onTap) {
    final textColor = isSelected ? Colors.white : Colors.black;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isSelected ? AppColors.triecoBaseBlue : Colors.white,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сливная станция $number',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: textColor,
                ),
              ),
              const Divider(),
              Text(
                plant.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Адрес',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plant.adress ?? "Адрес не указан",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (plant.latitude != null && plant.longitude != null)
                    IconButton(
                      icon: Icon(Icons.map, color: isSelected ? Colors.white : Colors.blue),
                      onPressed: () {
                        _openRoute(plant);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openRoute(TreatmentPlant plant) async {
    if (_currentPosition == null || plant.latitude == null || plant.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Невозможно построить маршрут из-за отсутствия координат')),
      );
      return;
    }

    final url = 'https://yandex.ru/maps/?mode=routes&rtext=${_currentPosition!.latitude},${_currentPosition!.longitude}~${plant.latitude},${plant.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Невозможно открыть карту')),
      );
    }
  }
} 