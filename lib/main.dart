import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart'; 
import 'package:keyah/styles/colors.dart';
import 'package:keyah/screens/initialization_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KeyahApp());
}

class KeyahApp extends StatelessWidget {
  const KeyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kéyah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: KeyahColors.primaryBlue,
        scaffoldBackgroundColor: KeyahColors.lightBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: KeyahColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: KeyahColors.primaryBlue,
          secondary: KeyahColors.actionOrange,
        ),
      ),
      // CORRECCIÓN AQUÍ:
      home: UpgradeAlert(
        // 1. El estilo va AQUÍ, directo en UpgradeAlert
        dialogStyle: UpgradeDialogStyle.cupertino, 
        
        upgrader: Upgrader(
          // 2. La configuración de idioma sigue aquí adentro
          languageCode: 'es', 
          countryCode: 'MX',
          // debugDisplayAlways: true, // Descomenta para probar
        ),
        child: const InitializationScreen(),
      ),
    );
  }
}