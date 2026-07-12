import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService();

  // Lectura síncrona del token JWT y el rol guardado
  String? token = await authService.getToken();
  String? role = prefs.getString('user_role');

  bool sesionActiva = false;
  bool esAdministrador = false;

  if (role == 'admin') {
    sesionActiva = true;
    esAdministrador = true;
  } else if (token != null) {
    sesionActiva = true;
    esAdministrador = false;
  }

  // Ejecución de la aplicación con el estado de autenticación recuperado
  runApp(EcoPulseApp(isLoggedIn: sesionActiva, isAdmin: esAdministrador));
}

class EcoPulseApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isAdmin;

  const EcoPulseApp({
    super.key,
    required this.isLoggedIn,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoPulse - Control de Aire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3:
            true,
      ),
      home: isLoggedIn ? HomeScreen(isAdmin: isAdmin) : const WelcomeScreen(),
    );
  }
}
