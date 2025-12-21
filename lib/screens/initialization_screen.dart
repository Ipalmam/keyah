import 'package:flutter/material.dart';
import 'package:keyah/styles/colors.dart';
import 'package:keyah/services/database_helper.dart';
import 'package:keyah/screens/home_screen.dart';

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final dbHelper = DatabaseHelper();
      
      // 1. Inicializar la base de datos
      await dbHelper.database; 
      
      // 2. Cargar los datos iniciales
      final associations = await dbHelper.getAssociations();

      // Simular delay estético
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 3. Navegar a la pantalla principal pasando los datos cargados
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // 2. CAMBIAMOS EL DESTINO A HOMESCREEN
          builder: (context) => HomeScreen(allAssociations: associations), // <--- CAMBIO AQUÍ
        ),
      );
    } catch (e) {
      debugPrint('Error inicializando app: $e');
      if (!mounted) return;
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error de Inicio'),
        content: Text('No se pudo cargar la base de datos: $message'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KeyahColors.primaryBlue, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.handshake, 
                size: 60, 
                color: KeyahColors.actionOrange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kéyah',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vínculo Comunitario',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: KeyahColors.actionOrange,
            ),
          ],
        ),
      ),
    );
  }
}