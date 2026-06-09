import 'package:flutter/material.dart';
import '../models/lectura_model.dart';
import '../models/reportes_models.dart';
import '../services/lectura_service.dart';
import '../services/api_services.dart';
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
  final ApiService _apiService = ApiService();
  late Future<List<LecturaModel>> _lecturasFuture;
  late Future<ReportePromedioGeneral> _reporteGeneralFuture;
  late Future<List<ZonaMasContaminada>> _topZonasFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _lecturasFuture = _lecturaService.fetchLecturas();
      _reporteGeneralFuture = _apiService.getPromedioGeneral();
      _topZonasFuture = _apiService.getZonasMasContaminadas();
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

  // Define la función para abrir el diálogo de añadir lectura (reutilizado)
  void _mostrarDialogoAnadirLectura() {
    final lecturaCO2 = TextEditingController();
    final lecturaNOx = TextEditingController();
    final lecturaPM25 = TextEditingController();
    final zonaIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.sensors, color: Colors.teal[700]),
                  const SizedBox(width: 10),
                  const Text('Inyección de Telemetría Manual'),
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: zonaIdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ID de la Zona',
                        hintText: 'Ej: 1',
                        prefixIcon: Icon(Icons.fingerprint),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lecturaCO2,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Valor de CO2',
                        hintText: 'Rango: (400.0 - 1200.0) ppm',
                        prefixIcon: Icon(Icons.speed),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lecturaNOx,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Valor de NOx',
                        hintText: 'Rango: (0.0 - 100.0) ppb',
                        prefixIcon: Icon(Icons.speed),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lecturaPM25,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Valor de PM2.5',
                        hintText: 'Rango: (0.0 - 150.0) μg/m³',
                        prefixIcon: Icon(Icons.speed),
                        border: OutlineInputBorder(),
                      ),
                    ),  
                    const SizedBox(height: 16)
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                  ),
                  onPressed: () async {
                    final String zonaId = zonaIdController.text.trim();
                    final String valorCO2 = lecturaCO2.text.trim();
                    final String valorNOx = lecturaNOx.text.trim();
                    final String valorPM25 = lecturaPM25.text.trim();
                    
                    if (valorCO2.isEmpty || zonaId.isEmpty|| valorNOx.isEmpty || valorPM25.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, rellene todos los campos.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    final int? zonaIdInt = int.tryParse(zonaId);
                    final double? valorCO2Double = double.tryParse(valorCO2);
                    final double? valorNOxDouble = double.tryParse(valorNOx);
                    final double? valorPM25Double = double.tryParse(valorPM25);
                    if (zonaIdInt == null 
                    ||valorCO2Double == null || valorCO2Double < 400.0 || valorCO2Double > 1200.0
                    || valorNOxDouble == null || valorNOxDouble < 0.0 || valorNOxDouble > 100.0 
                    || valorPM25Double == null || valorPM25Double < 0.0 || valorPM25Double > 150.0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Los valores deben ser numéricos y válidos.',
                          ),
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
                    bool exito = await _lecturaService.enviarLectura(
                      idZona: zonaIdInt,
                      co2: valorCO2Double,
                      nox: valorNOxDouble,
                      pm25: valorPM25Double,
                    );
                    if (!mounted) return;
                    if (exito) {
                      _refreshData();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '¡Éxito! Nueva lectura de la zona $zonaIdInt agregada.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error en ecopulse.db. Revisa la consola de FastAPI o el Token.',
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Registrar Dato',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Determina el color principal del widget de calidad del aire basándose en el índice de getPromedioGeneral()
  Color _getAirQualityStatusColor(double? index) {
    if (index == null) return Colors.green; // Default si no hay datos
    if (index > 0.80) return Colors.grey;
    if (index > 0.60) return Colors.redAccent;
    if (index > 0.40) return Colors.orangeAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.isAdmin
              ? 'EcoPulse - Panel Administrativo'
              : 'EcoPulse - Panel de Control',
        ),
        backgroundColor: widget.isAdmin
            ? Colors.blueGrey[800]
            : Colors.teal[700], // Cambia el color según el rol
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Widget principal para el estado de calidad del aire 
            //basándose en el índice global obtenido de getPromedioGeneral()
            FutureBuilder<ReportePromedioGeneral>(
              future: _reporteGeneralFuture,
              builder: (context, reportSnap) {
                double? indiceGlobal;
                if (reportSnap.hasData) {
                  indiceGlobal = reportSnap.data!.indiceGlobal;
                }
                return _buildMainStatusCard(indiceGlobal);
              },
            ),
            const SizedBox(height: 24),

            // Sección de promedios globales obtenidos de getPromedioGeneral()
            const Text(
              'Promedios Globales',//De todas las lecturas registradas en ecopulse.db
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<ReportePromedioGeneral>(
              future: _reporteGeneralFuture,
              builder: (context, reportSnap) {
                if (reportSnap.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator(color: Colors.teal);
                } else if (reportSnap.hasError) {
                  return const Center(
                    child: Text('Error al cargar promedios generales.'),
                  );
                } else if (reportSnap.hasData) {
                  final r = reportSnap.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSmallStat(
                        "Prom. CO2",
                        "${r.promedioCo2}",
                      ),
                      _buildSmallStat(
                        "Prom. NOx",
                        "${r.promedioNox}",
                      ),
                      _buildSmallStat(
                        "Prom. PM25",
                        "${r.promedioPm25}",
                      ),
                    ],
                  );
                }
                return const LinearProgressIndicator(color: Colors.teal);
              },
            ),
            const SizedBox(height: 24),

            // Sección de las 3 estaciones más contaminadas obtenidas de getZonasMasContaminadas()
            const Text(
              'Top 3 estaciones más contaminadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<ZonaMasContaminada>>(
              future: _topZonasFuture,
              builder: (context, topSnap) {
                if (topSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (topSnap.hasError) {
                  return const Center(
                    child: Text('Error al cargar top zonas mas contaminadas.'),
                  );
                } else if (topSnap.hasData && topSnap.data!.isNotEmpty) {
                  final lista = topSnap.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStationCard(
                        lista.isNotEmpty ? lista[0].nombre : 'Zona N/A',
                        lista.isNotEmpty
                            ? lista[0].indice.toStringAsFixed(2)
                            : 'N/A',
                      ),
                      _buildStationCard(
                        lista.length > 1 ? lista[1].nombre : 'Zona N/A',
                        lista.length > 1
                            ? lista[1].indice.toStringAsFixed(2)
                            : 'N/A',
                      ),
                      _buildStationCard(
                        lista.length > 2 ? lista[2].nombre : 'Zona N/A',
                        lista.length > 2
                            ? lista[2].indice.toStringAsFixed(2)
                            : 'N/A',
                      ),
                    ],
                  );
                }
                return const Center(
                  child: Text('Datos de estaciones no disponibles.'),
                );
              },
            ),
            const SizedBox(height: 24),

            // Sección de historial de capturas recientes obtenidas de fetchLecturas()
            const Text(
              'Historial de Capturas Recientes (5 últimas lecturas)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Historial de Capturas Recientes - Muestra las lecturas de fetchLecturas()
            _buildHistorialListar(widget.isAdmin),
          ],
        ),
      ),

      // Botón flotante para añadir lectura, visible solo para administradores
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.blueGrey[800],
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Añadir Lectura',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _mostrarDialogoAnadirLectura,
            )
          : null,
    );
  }

  // WIDGETS

  // Widget para listar el historial de capturas recientes y abrir el diálogo de detalle
  Widget _buildHistorialListar(bool isAdmin) {
    return FutureBuilder<List<LecturaModel>>(
      future: _lecturasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(); // No mostrar nada mientras carga
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al conectar con ecopulse.db:\n${snapshot.error}',
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final lista = snapshot.data!;
          // Listado histórico de fetchLecturas()
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lista.length > 5 ? 5 : lista.length, // Mostrar máximo 5
            itemBuilder: (context, index) {
              // Mostramos el historial en orden inverso (más nuevo primero)
              final lecturaHistorial = lista[lista.length - 1 - index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    // Diálogo de detalle de lectura (reutilizado)
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.assessment,
                              color:
                                  lecturaHistorial.idZona.toString() == 'Cargando...'
                                  ? Colors.redAccent
                                  : Colors.teal[700],
                            ),
                            const SizedBox(width: 10),
                            Text('Detalle de Captura #${lecturaHistorial.id}'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zona ID: ${lecturaHistorial.idZona}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Fecha/Hora: ${lecturaHistorial.timestamp}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Divider(height: 24),

                            _buildFilaDetalleGas(
                              'Dióxido de Carbono (CO2):',
                              '${lecturaHistorial.co2} ppm',
                            ),
                            const SizedBox(height: 8),
                            _buildFilaDetalleGas(
                              'Óxidos de Nitrógeno (NOx):',
                              '${lecturaHistorial.nox} ppb',
                            ),
                            const SizedBox(height: 8),
                            _buildFilaDetalleGas(
                              'Partículas finas (PM2.5):',
                              '${lecturaHistorial.pm25} µg/m³',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cerrar',
                              style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Icon(Icons.analytics, color: Colors.teal[700]),
                    title: Text('Zona ID: ${lecturaHistorial.idZona}'),
                    subtitle: Text(
                      'CO2: ${lecturaHistorial.co2} | NOx: ${lecturaHistorial.nox} | PM2.5: ${lecturaHistorial.pm25}',
                    ),
                    trailing: Text(
                      'ID: ${lecturaHistorial.id}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const Center(
          child: Text('No hay capturas registradas recientemente todavía.'),
        );
      },
    );
  }

  // Fila de detalle para el diálogo
  Widget _buildFilaDetalleGas(String etiqueta, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Widget principal para el estado de calidad del aire basándose en el índice global
  Widget _buildMainStatusCard(double? dataIndex) {
    String status = "Excelente";
    if (dataIndex == null) {
      status = "Cargando...";
    } else if (dataIndex > 0.80) {
      status = "Crítico";
    } else if (dataIndex > 0.60) {
      status = "Alto";
    } else if (dataIndex > 0.40) {
      status = "Moderado";
    } else {
      status = "Bueno";
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _getAirQualityStatusColor(dataIndex),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.air, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            const Text(
              'Índice de la Calidad del Aire Global',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              dataIndex == null
                  ? 'Cargando...'
                  : '${dataIndex.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Calidad: $status',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para las estadísticas de los promedios globales
  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  // Widget para las tarjetas de las estaciones mas contaminadas
  Widget _buildStationCard(String name, String indexValue) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              indexValue,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const Text(
              'Índice',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
