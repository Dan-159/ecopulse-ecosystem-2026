import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/lectura_model.dart';

class LecturaService {
  final String baseUrl = "http://127.0.0.1:8000"; //10.0.2.2 si es emulador Android

  // Método para traer todas las lecturas de ecopulse.db
  Future<List<LecturaModel>> fetchLecturas() async {
    // 1. Recuperamos de forma segura la llave JWT desde el SharedPreferences
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      // 2. Apuntamos al endpoint GET de tu lecturas_router
      final response = await http.get(
        Uri.parse('$baseUrl/lecturas/'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          // CRÍTICO: Enviamos el token para que OAuth2PasswordBearer valide el acceso
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 4));

      // 3. Si el servidor responde exitosamente
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
      print("❌ Error en LecturaService: $e");
      rethrow;
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