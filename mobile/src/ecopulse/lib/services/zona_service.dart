import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ZonaService {
  final String baseUrl = "http://127.0.0.1:8000";

  // Método para enviar una nueva zona al backend
  Future<bool> enviarZona({
    required String nombre,
    required String ubicacion,
  }) async {
    final url = Uri.parse('$baseUrl/zonas/');
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
              "nombre": nombre,
              "ubicacion": ubicacion,
            }),
          )
          .timeout(const Duration(seconds: 4));

      print(
        "Respuesta de inserción de zona: ${response.statusCode} -> ${response.body}",
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      // CONTROL DE EXPIRACIÓN:
      else if (response.statusCode == 401) { // [cite: 145]
        print("🚨 Sesión inválida o expirada. Limpiando token local...");
        await authService.logout();

        throw Exception("Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.");
      } else {
        print("Error al insertar zona. Código: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error de red al propagar la nueva zona: $e");
      return false;
    }
  }
}