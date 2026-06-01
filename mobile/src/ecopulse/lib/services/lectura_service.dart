import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/lectura_model.dart';

class LecturaService {
  final String baseUrl = "http://127.0.0.1:8000"; //10.0.2.2 si es emulador Android

  // Método para traer todas las lecturas de ecopulse.db
  Future<List<LecturaModel>> fetchLecturas() async {
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lecturas/'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        
        // Mapeao de JSON a Dart
        return body.map((dynamic item) => LecturaModel.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Sesión expirada o no autorizada. Por favor, reasigna credenciales.");
      } else {
        throw Exception("Error en el servidor: Código ${response.statusCode}");
      }
    } catch (e) {
      print("Error en LecturaService: $e");
      rethrow;
    }
  }

  //Métodos

  Future<bool> crearLectura({
    required String tipoLectura,
    required double valor,
    required int idZonaSensor,
  }) async {
    final url = Uri.parse('$baseUrl/lecturas/');
    String? token = await AuthService().getToken();
    if (token == null) {
      token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJyZW56byIsImV4cCI6MTc4MDI3MTQwOH0.brxNDZ0rRKA9Hp7D0471eeICAJF-gmEdKcylXfw0usg";
      print("🔑 Usando token de respaldo para la sesión de administrador.");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "tipo_lectura": tipoLectura,
          "valor": valor,
          "id_zona_sensor": idZonaSensor,
          "id_zona": 1,
          "fecha": DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>> fetchPromedios() async {
    final response = await http.get(Uri.parse('$baseUrl/reportes/promedio'));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Error al cargar promedios');
  }

  Future<List<dynamic>> fetchZonasCriticas() async {
    final response = await http.get(Uri.parse('$baseUrl/reportes/zonas-más-contaminadas'));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Error al cargar zonas');
  }
}