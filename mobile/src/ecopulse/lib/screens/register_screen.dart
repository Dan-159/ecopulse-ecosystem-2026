import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    final username = _userController.text.trim();
    final password = _passController.text;
    final confirmPass = _confirmPassController.text;

    if (username.isEmpty || password.isEmpty) {
      _mostrarSnack('Por favor, completa todos los campos.');
      return;
    }

    if (password != confirmPass) {
      _mostrarSnack('Las contraseñas no coinciden.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await AuthService().register(username, password);

      if (!mounted) return;

      if (success) {
        _mostrarSnack('¡Cuenta creada con éxito! Ya puedes iniciar sesión.', esExito: true);
        Navigator.pop(context);
      } else {
        _mostrarSnack('El nombre de usuario ya está registrado en ecopulse.db.');
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarSnack('No se pudo conectar con el servidor de EcoPulse.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarSnack(String mensaje, {bool esExito = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esExito ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 53, 130, 58),
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.teal,
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
              const Text(
                'Crear nueva cuenta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              const Text('Regístrate para acceder a la telemetría del sistema.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Usuario',
                  prefixIcon: Icon(Icons.person, color: Colors.teal),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock, color: Colors.teal),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.teal),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        onPressed: _handleRegister,
                        child: const Text('Registrar Cuenta', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}