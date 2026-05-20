import 'package:flutter/material.dart';
import '../models/lectura_model.dart';
import '../services/lectura_service.dart';
import '../services/auth_service.dart';
import 'welcome.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LecturaService _lecturaService = LecturaService();
  late Future<List<LecturaModel>> _lecturasFuture;
  // Nueva variable para los reportes generales
  late Future<Map<String, dynamic>> _reportesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _lecturasFuture = _lecturaService.fetchLecturas();
      // Invocamos el endpoint de promedios de reportes.py
      _reportesFuture = _lecturaService.fetchPromedios(); 
    });
  }

  void _handleLogout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
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
        title: const Text('EcoPulse - Panel de Control'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: FutureBuilder<List<LecturaModel>>(
        future: _lecturasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error al conectar con ecopulse.db:\n${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final lista = snapshot.data!;
            final ultimaLectura = lista.last; 

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainStatusCard(ultimaLectura),
                  const SizedBox(height: 24),

                  // --- NUEVA SECCIÓN DE REPORTES (PROMEDIOS GENERALES) ---
                  const Text(
                    'Resumen Histórico General',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _reportesFuture,
                    builder: (context, reportSnap) {
                      if (reportSnap.hasData) {
                        final r = reportSnap.data!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSmallStat("Prom. CO2", "${r['promedio_co2'].toStringAsFixed(1)}"),
                            _buildSmallStat("Prom. NOx", "${r['promedio_nox'].toStringAsFixed(1)}"),
                            _buildSmallStat("Prom. PM25", "${r['promedio_pm25'].toStringAsFixed(1)}"),
                          ],
                        );
                      }
                      return const LinearProgressIndicator(color: Colors.teal);
                    },
                  ),
                  const SizedBox(height: 24),
                  // -------------------------------------------------------
                  
                  const Text(
                    'Indicadores en Tiempo Real',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIndicatorCard('PM2.5', '${ultimaLectura.pm25}', 'µg/m³', ultimaLectura.pm25 > 50 ? Colors.red : Colors.blue),
                      _buildIndicatorCard('CO2', '${ultimaLectura.co2}', 'ppm', ultimaLectura.co2 > 1000 ? Colors.red : Colors.blue),
                      _buildIndicatorCard('NOx', '${ultimaLectura.nox}', 'ppb', ultimaLectura.nox > 100 ? Colors.red : Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Historial de Capturas Recientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final lecturaHistorial = lista[lista.length - 1 - index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(Icons.analytics, color: _getStatusColor(lecturaHistorial.status)),
                            title: Text('Sensor ID: ${lecturaHistorial.sensorId} | Estado: ${lecturaHistorial.status}'),
                            subtitle: Text('Fecha: ${lecturaHistorial.timestamp}'),
                            trailing: Text('ID: ${lecturaHistorial.id}', style: const TextStyle(color: Colors.grey)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No hay lecturas registradas en ecopulse.db todavía.'));
        },
      ),
    );
  }

  // Widget auxiliar para las estadísticas pequeñas del reporte
  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
      ],
    );
  }

  Widget _buildMainStatusCard(LecturaModel data) {
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
              'Sensor de Monitoreo #${data.id}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              'Calidad: ${data.status}',
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
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}