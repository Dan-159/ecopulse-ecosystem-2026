import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reportes_models.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000"; //10.0.2.2 si es emulador Android

  // Obtener Promedios Globales
  Future<ReportePromedioGeneral> getPromedioGeneral() async {
    final response = await http.get(Uri.parse('$baseUrl/reportes/promedio-general'));
    if (response.statusCode == 200) {
      return ReportePromedioGeneral.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar promedios: ${response.statusCode}');
    }
  }

  // Obtener Top 3 Zonas Contaminadas
  Future<List<ZonaMasContaminada>> getZonasMasContaminadas() async {
    final response = await http.get(Uri.parse('$baseUrl/reportes/top-3-zonas-contaminadas'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => ZonaMasContaminada.fromJson(data))
          .toList();
    } else {
      throw Exception('Error al cargar zonas: ${response.statusCode}');
    }
  }
}