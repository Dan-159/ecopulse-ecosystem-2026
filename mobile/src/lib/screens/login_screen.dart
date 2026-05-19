import 'package:flutter/material.dart';
import '../services/auth_services.dart';
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
  
  void _handleLogin() async {
    setState(() => _isLoading = true);
    bool success = await AuthService().login(_userController.text,_passController.text,);
    
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas o servidor offline'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - Ecopulse'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  controller: _userController,
                  decoration: const InputDecoration(labelText: 'Usuario', border: OutlineInputBorder(),icon: Icon(Icons.person)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  controller: _passController,
                  decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder(),icon: Icon(Icons.lock)),
                  obscureText: true,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Iniciar Sesión',style: TextStyle(color: Colors.teal,)
                    ,),
                  ),
          ],
        ),
      ),
    );
  }
}
