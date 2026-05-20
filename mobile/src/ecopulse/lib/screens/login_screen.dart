import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  void _mostrarMensajeError(String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.redAccent, // Añadimos color para que resalte
      duration: const Duration(seconds: 4),
    ),
  );
}
  void _handleLogin() async {
  setState(() => _isLoading = true); // animación de carga
  // El AuthService guarda el token internamente si el login es exitoso
  try {
    bool success = await AuthService().login(
    _userController.text,
    _passController.text
  );
    setState(() => _isLoading = false);
    if (!mounted) return; 

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen())
      );
    } else {
      _mostrarMensajeError('Credenciales incorrectas');
    }
  }
  catch (e) {
    setState(() => _isLoading = false);
    if (!mounted) return;
    _mostrarMensajeError('No se pudo conectar con el servidor de SMAT');
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoPulse Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText:
            'Usuario')),
            TextField(controller: _passController, decoration: const InputDecoration(labelText:
            'Contraseña'), obscureText: true),
            const SizedBox(height: 30),
            _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _handleLogin, child: const Text('Iniciar Sesión'))
          ],
        ),
      ),
    );
  }
}