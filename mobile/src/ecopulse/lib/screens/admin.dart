import 'package:ecopulse/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  //CONTRASEÑA PARA ADMINISTRADORES
  static const String _adminUser = "admin_fisi";
  static const String _adminPass = "ecopulse2026";
/*
  void _handleAdminLogin() async {
    final username = _userController.text.trim();
    final password = _passController.text;
    final authService = AuthService();

    if (username.isEmpty || password.isEmpty) {
      _mostrarSnack('Por favor, completa las credenciales de acceso.');
      return;
    }

    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isLoading = false);

    if (username == _adminUser && password == _adminPass) {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'admin');

      _mostrarSnack('¡Acceso concedido como Personal Autorizado!', esExito: true);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen(isAdmin: true)),
      );
    } else {
      if (!mounted) return;
      _mostrarSnack('Credenciales de personal no autorizadas o incorrectas.');
    }
  }
*/
  void _handleAdminLogin() async {
    final username = _userController.text.trim();
    final password = _passController.text;

    if (username.isEmpty || password.isEmpty) {
      _mostrarSnack('Por favor, completa las credenciales de acceso.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validación local del panel administrativo
      if (username != _adminUser || password != _adminPass) {
        setState(() => _isLoading = false);

        if (!mounted) return;

        _mostrarSnack('Credenciales de personal no autorizadas o incorrectas.');
        return;
      }

      // Login contra FastAPI para obtener JWT actualizado
      final authService = AuthService();

      final loginExitoso = await authService.login(username, password);

      if (!loginExitoso) {
        setState(() => _isLoading = false);

        if (!mounted) return;

        _mostrarSnack('No se pudo obtener el token de autenticación.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'admin');

      setState(() => _isLoading = false);

      if (!mounted) return;

      _mostrarSnack(
        '¡Acceso concedido como Personal Autorizado!',
        esExito: true,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(isAdmin: true),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      _mostrarSnack('Error de conexión con el servidor: $e');
    }
  }
  
  void _mostrarSnack(String mensaje, {bool esExito = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esExito ? Colors.teal : Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      appBar: AppBar(
        title: const Text('Módulo de Inspección'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blueGrey[800],
      ),
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(40.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield, color: Colors.blueGrey[800], size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'Acceso de Personal',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Restringido únicamente para ingenieros de control ambiental o auditoría.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: 'Código / Usuario de Personal',
                  prefixIcon: Icon(Icons.badge, color: Colors.blueGrey[800]),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Llave de Seguridad',
                  prefixIcon: Icon(Icons.vpn_key, color: Colors.blueGrey[800]),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[800]),
                        onPressed: _handleAdminLogin,
                        child: const Text('Validar Identidad', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}