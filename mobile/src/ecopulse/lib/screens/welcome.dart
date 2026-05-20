import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 98, 71), // Fondo gris-verdoso claro
      body: Center(
        child: Container(
          width: 450, // Limita el ancho para que en web no se estire feo
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
            mainAxisSize: MainAxisSize.min, // Se acopla al contenido
            children: [
              const Icon(Icons.eco, size: 80, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                'EcoPulse',
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.teal
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sistema de Monitoreo de Calidad del Aire\nFISI - UNMSM',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),
              
              // BOTÓN INICIAR SESIÓN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              
              // BOTÓN CREAR CUENTA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.teal, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Crear Cuenta', style: TextStyle(color: Colors.teal, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}