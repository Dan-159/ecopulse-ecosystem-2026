import 'package:flutter/material.dart';
import '../models/lectura_model.dart';
import '../services/lectura_service.dart';
import '../services/auth_service.dart';
import 'welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin; 
  const HomeScreen({super.key, this.isAdmin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LecturaService _lecturaService = LecturaService();
  late Future<List<LecturaModel>> _lecturasFuture;
  late Future<Map<String, dynamic>> _reportesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _lecturasFuture = _lecturaService.fetchLecturas();
      _reportesFuture = _lecturaService.fetchPromedios(); 
    });
  }

  void _handleLogout() async {
    await AuthService().logout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

void _mostrarDialogoAnadirLectura() {
  final valorController = TextEditingController();
  final sensorIdController = TextEditingController();
  
  // Opciones válidas que acepta tu backend y tu lectura_model
  final List<String> tiposDeGas = ['co2', 'pm25', 'nox'];
  String gasSeleccionado = 'co2'; // Valor por defecto

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.sensors, color: Colors.teal),
                SizedBox(width: 10),
                Text('Inyección de Telemetría Manual'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formulario exclusivo para administradores e ingenieros de control.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Text('Tipo de Métrica / Gas:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: gasSeleccionado,
                        isExpanded: true,
                        items: tiposDeGas.map((String gas) {
                          return DropdownMenuItem<String>(
                            value: gas,
                            child: Text(gas.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (nuevoValor) {
                          // Crucial: Cambia el estado interno del modal
                          setDialogState(() {
                            gasSeleccionado = nuevoValor!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. Campo para ingresar el valor numérico cuantitativo
                  TextField(
                    controller: valorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valor Cuantitativo',
                      hintText: 'Ej: 45.2',
                      prefixIcon: Icon(Icons.speed),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sensorIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ID del Sensor (id_zona_sensor)',
                      hintText: 'Ej: 1',
                      prefixIcon: Icon(Icons.fingerprint),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700]),
                onPressed: () async {
                  final String valorTexto = valorController.text.trim();
                  final String sensorTexto = sensorIdController.text.trim();

                  if (valorTexto.isEmpty || sensorTexto.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, rellene todos los campos.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final double? valorDouble = double.tryParse(valorTexto);
                  final int? sensorIdInt = int.tryParse(sensorTexto);

                  if (valorDouble == null || sensorIdInt == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Los valores deben ser numéricos válidos.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.of(context).pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Conectando con ecopulse.db...'),
                      duration: Duration(milliseconds: 500),
                    ),
                  );

                  //PETICIÓN ASÍNCRONA A FASTAPI
                  bool exito = await _lecturaService.crearLectura(
                    tipoLectura: gasSeleccionado,
                    valor: valorDouble,
                    idZonaSensor: sensorIdInt,
                  );

                  //Verifica si el widget sigue vivo en pantalla
                  if (!mounted) return;

                  if (exito) {
                    _refreshData(); 
                    
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('¡Éxito! Nueva lectura de ${gasSeleccionado.toUpperCase()} agregada.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Error en ecopulse.db. Revisa la consola de FastAPI o el Token.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text('Registrar Dato', style: TextStyle(color: Colors.white)),
              )
            ],
          );
        },
      );
    },
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
        title: Text(widget.isAdmin ? 'EcoPulse - Panel Administrativo' : 'EcoPulse - Panel de Control'),
        backgroundColor: widget.isAdmin ? Colors.blueGrey[800] : Colors.teal, // Cambia el color según el rol
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
            return Center(child: Text('Error al conectar con ecopulse.db:\n${snapshot.error}'));
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
                  const Text('Indicadores en Tiempo Real', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  const Text('Historial de Capturas Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        // Mostramos el historial en orden inverso (más nuevo primero)
                        final lecturaHistorial = lista[lista.length - 1 - index];
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: Row(
                                    children: [
                                      Icon(Icons.assessment, color: _getStatusColor(lecturaHistorial.status)),
                                      const SizedBox(width: 10),
                                      Text('Detalle de Captura #${lecturaHistorial.id}'),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Estado: ${lecturaHistorial.status}',
                                        style: TextStyle(
                                          fontSize: 18, 
                                          fontWeight: FontWeight.bold, 
                                          color: _getStatusColor(lecturaHistorial.status)
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Registrado por Sensor ID: ${lecturaHistorial.sensorId}', style: const TextStyle(color: Colors.grey)),
                                      Text('Fecha/Hora: ${lecturaHistorial.timestamp}', style: const TextStyle(color: Colors.grey)),
                                      const Divider(height: 24),
                                      
                                      // Desglose cuantitativo por tipo de gas/métrica
                                      _buildFilaDetalleGas('Material Particulado (PM2.5):', '${lecturaHistorial.pm25} µg/m³'),
                                      const SizedBox(height: 8),
                                      _buildFilaDetalleGas('Dióxido de Carbono (CO2):', '${lecturaHistorial.co2} ppm'),
                                      const SizedBox(height: 8),
                                      _buildFilaDetalleGas('Óxidos de Nitrógeno (NOx):', '${lecturaHistorial.nox} ppb'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cerrar', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: ListTile(
                              leading: Icon(Icons.analytics, color: _getStatusColor(lecturaHistorial.status)),
                              title: Text('Sensor ID: ${lecturaHistorial.sensorId} | Estado: ${lecturaHistorial.status}'),
                              subtitle: Text('PM2.5: ${lecturaHistorial.pm25} | CO2: ${lecturaHistorial.co2} | NOx: ${lecturaHistorial.nox}'),
                              trailing: Text('ID: ${lecturaHistorial.id}', style: const TextStyle(color: Colors.grey)),
                            ),
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

      //Solo admin
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.blueGrey[800],
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Añadir Estación', style: TextStyle(color: Colors.white)),
              onPressed: _mostrarDialogoAnadirLectura,
            )
          : null, // Si no es admin, se le pasa null y Flutter esconde el botón
    );
  }

  // WIDGETS

  Widget _buildFilaDetalleGas(String etiqueta, String valor) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
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

  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
      ],
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