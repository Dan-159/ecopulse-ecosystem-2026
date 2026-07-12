import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/lectura_model.dart';

class LecturaService {
  final String baseUrl = "http://127.0.0.1:8000";

  // Método para traer todas las lecturas de ecopulse.db
  Future<List<LecturaModel>> fetchLecturas() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/lecturas/'),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => LecturaModel.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        throw Exception("No se encontraron lecturas registradas.");
      } else {
        throw Exception("Error en el servidor: Código ${response.statusCode}");
      }
    } catch (e) {
      print("Error en fetchLecturas: $e");
      rethrow;
    }
  }
  
  // Método para enviar una nueva lectura al backend
  Future<bool> enviarLectura({
    required int idZona,
    required double co2,
    required double nox,
    required double pm25,
  }) async {
    final url = Uri.parse('$baseUrl/lecturas/');
    final authService = AuthService();
    String? token = await authService.getToken();
    if (token == null) {
      throw Exception("No existe una sesión autenticada.");
    }

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({
              "id_zona": idZona,
              "lectura_de_co2": co2,
              "lectura_de_nox": nox,
              "lectura_de_pm25": pm25,
            }),
          )
          .timeout(const Duration(seconds: 4));

      print(
        "Respuesta de inserción de métrica: ${response.statusCode} -> ${response.body}",
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      // CONTROL DE EXPIRACIÓN
      else if (response.statusCode == 401) {
        print("🚨 Sesión inválida o expirada. Limpiando token local...");
        await authService.logout(); // Borra el token obsoleto de SharedPreferences

        throw Exception("Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.");
        //return false;
      } else {
        print("Error al insertar métrica. Código: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error de red al propagar lectura IoT: $e");
      return false;
    }
  }
}
