import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/eco_models.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000"; //10.0.2.2 si es emulador Android

  // Obtener Promedios Globales
  Future<ReportePromedio> getPromedios() async {
    final response = await http.get(Uri.parse('$baseUrl/reportes/promedio'));
    if (response.statusCode == 200) {
      return ReportePromedio.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar promedios');
    }
  }

  // Obtener Top 5 Zonas Contaminadas
  Future<List<ZonaReporte>> getZonasMasContaminadas() async {
    final response = await http.get(Uri.parse('$baseUrl/reportes/zonas-más-contaminadas'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ZonaReporte.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar zonas');
    }
  }
}