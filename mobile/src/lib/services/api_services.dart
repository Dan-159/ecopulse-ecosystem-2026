import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/air_quality_model.dart';
import '../models/zonas_model.dart';
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<AirQualityModel> fetchCurrentAirQuality() async {
    try {
       
      // CÓDIGO REAL PARA PRODUCCIÓN:
      final response = await http.get(Uri.parse('$baseUrl/reportes/promedio'));
      if (response.statusCode == 200) {
        return AirQualityModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar datos de la nube');
      }

    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  Future<List<Zona>> fetchZonas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reportes/zonas-más-contaminadas'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<Zona> zonas = data.map((item) => Zona.fromJson(item)).toList();
        zonas.sort((a, b) => b.promedioGeneral.compareTo(a.promedioGeneral));
        List<Zona> top3 = zonas.take(3).toList();
        return top3;
      } else {
        throw Exception('Error al cargar datos de zonas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

}