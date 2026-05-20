import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';  // Ajusta la ruta según tus carpetas
import 'screens/welcome.dart';

void main() async {
  // 1. CRÍTICO: Asegura que los enlaces de Flutter estén listos antes de usar código nativo
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Instanciamos el servicio y verificamos si hay un token guardado
  final authService = AuthService();
  String? token = await authService.getToken();

  // 3. Si token no es nulo, significa que hay sesión activa
  final bool sesionActiva = token != null;

  runApp(EcoPulseApp(isLoggedIn: sesionActiva));
}

class EcoPulseApp extends StatelessWidget {
  final bool isLoggedIn;

  const EcoPulseApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMAT API - Control de Aire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      // CONTROL DE PERSISTENCIA:
      // Si está logueado va directo a HomeScreen, si no, se queda en WelcomenScreen
      home: isLoggedIn ? const HomeScreen() : const WelcomeScreen(),
    );
  }
}