import 'package:flutter/material.dart';
import '../models/air_quality_model.dart';
import '../services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<AirQualityModel> _airQualityFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _airQualityFuture = _apiService.fetchCurrentAirQuality();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Crítico': return Colors.redAccent;
      case 'Moderado': return Colors.orangeAccent;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('EcoPulse - Calidad de Aire'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      body: FutureBuilder<AirQualityModel>(
        future: _airQualityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainStatusCard(data),
                  const SizedBox(height: 24),
                  const Text(
                    'Indicadores Detallados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIndicatorCard('PM2.5', '${data.pm25}', 'µg/m³', data.pm25 > 50 ? Colors.red : Colors.blue),
                      _buildIndicatorCard('CO2', '${data.co2}', 'ppm', data.co2 > 1000 ? Colors.red : Colors.blue),
                      _buildIndicatorCard('NOx', '${data.nox}', 'µg/m³', data.nox > 100 ? Colors.red : Colors.blue),
                    ],
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No hay datos disponibles'));
        },
      ),
    );
  }

  Widget _buildMainStatusCard(AirQualityModel data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _getStatusColor(data.status),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.air, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              data.location,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              'Estado: ${data.status}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorCard(String title, String value, String unit, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(unit, style: const TextStyle(fontSize: 12, color:Colors.grey)),
          ],
        ),
      ),
    );
  }
}