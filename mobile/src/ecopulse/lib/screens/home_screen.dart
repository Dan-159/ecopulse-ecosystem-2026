import 'package:flutter/material.dart';
import '../models/lectura_model.dart';
import '../models/reportes_models.dart';
import '../services/zona_service.dart';
import '../services/api_services.dart';
import '../services/auth_service.dart';
import '../services/lecturas_service.dart';
import 'welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> _distritosLima = [
  'Ancón', 'Ate', 'Barranco', 'Breña', 'Carabayllo', 'Chaclacayo', 'Chorrillos',
  'Cieneguilla', 'Comas', 'El Agustino', 'Independencia', 'Jesús María', 'La Molina',
  'La Victoria', 'Lima (Cercado)', 'Lince', 'Los Olivos', 'Lurigancho-Chosica', 'Lurín',
  'Magdalena del Mar', 'Miraflores', 'Pachacámac', 'Pucusana', 'Pueblo Libre',
  'Puente Piedra', 'Punta Hermosa', 'Punta Negra', 'Rímac', 'San Bartolo',
  'San Borja', 'San Isidro', 'San Juan de Lurigancho', 'San Juan de Miraflores',
  'San Luis', 'San Martín de Porres', 'San Miguel', 'Santa Anita', 'Santa María del Mar',
  'Santa Rosa', 'Santiago de Surco', 'Surquillo', 'Villa El Salvador', 'Villa María del Triunfo'
];

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  const HomeScreen({super.key, this.isAdmin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ZonaService _zonaService = ZonaService();
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

  void _mostrarDialogoAnadirZona() {
    final ubicacionZonaController = TextEditingController();
    String distritoSeleccionado = "";

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
                  Icon(Icons.map, color: Colors.teal[700]),
                  const SizedBox(width: 10),
                  const Text('Registrar Nueva Zona'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Formulario exclusivo para administradores para la expansión de la red de monitoreo.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo: Nombre de la Zona
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _distritosLima.where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        distritoSeleccionado = selection;
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Seleccione el Distrito (Lima Metropolitana)',
                            hintText: 'Escribe para buscar (Ej: Miraflores)',
                            prefixIcon: Icon(Icons.map_outlined),
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    
                    // Campo: Ubicación
                    TextField(
                      controller: ubicacionZonaController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación / Dirección',
                        hintText: 'Ej: Av. Principal 123 o Coordenadas',
                        prefixIcon: Icon(Icons.location_on),
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
                    final String nombre = distritoSeleccionado.trim();
                    final String ubicacion = ubicacionZonaController.text.trim();

                    if (nombre.isEmpty || !_distritosLima.contains(nombre)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, seleccione un distrito válido de la lista.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (ubicacion.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, ingrese la ubicación específica.'),
                          backgroundColor: Colors.orange,
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

                    // Llamada al backend:
                    bool exito = await _zonaService.enviarZona(
                      nombre: nombre,
                      ubicacion: ubicacion,
                    );

                    if (!mounted) return;

                    if (exito) {
                      _refreshData();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('¡Éxito! La zona "$nombre" ha sido agregada.'),
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
                    'Registrar Zona',
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
            : Colors.teal[700],
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

            const Text(
              'Promedios Globales',
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
            const Text(
              'Historial de Capturas Recientes (5 últimas lecturas)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildHistorialListar(widget.isAdmin),
          ],
        ),
      ),

      // Botón flotante para añadir zona
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.blueGrey[800],
              icon: const Icon(Icons.add_location_alt, color: Colors.white),
              label: const Text(
                'Añadir Zona',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _mostrarDialogoAnadirZona,
            )
          : null,
    );
  }

  // WIDGETS

  // Historial de capturas recientes
  Widget _buildHistorialListar(bool isAdmin) {
    return FutureBuilder<List<LecturaModel>>(
      future: _lecturasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al conectar con ecopulse.db:\n${snapshot.error}',
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final lista = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lista.length > 5 ? 5 : lista.length,
            itemBuilder: (context, index) {
              final lecturaHistorial = lista[lista.length - 1 - index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
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

  // Estado de calidad del aire
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

  // Estadísticas de los promedios globales
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

  // Tarjetas de las estaciones mas contaminadas
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
