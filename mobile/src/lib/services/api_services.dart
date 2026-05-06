// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../models/air_quality_model.dart';

class ApiService {
  // Reemplaza esta URL con el endpoint real de tu nube (AWS, Firebase, Azure, etc.)
  static const String apiUrl = 'https://tu-api-nube.com/api/v1/air-quality/current';

  Future<AirQualityModel> fetchCurrentAirQuality() async {
    try {
      /* 
      // CÓDIGO REAL PARA PRODUCCIÓN:
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return AirQualityModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar datos de la nube');
      }
      */

      // DATOS SIMULADOS (Mock) PARA QUE PRUEBES LA INTERFAZ AHORA MISMO:
      await Future.delayed(const Duration(seconds: 2)); // Simula tiempo de red
      return AirQualityModel(
        pm25: 42.5, // Nivel moderado/alto
        co2: 850.0,
        nox: 45.2,
        location: 'Parque Industrial Sur',
      );

    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}