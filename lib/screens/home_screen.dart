import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'association_search_screen.dart';
import 'reports_screen.dart';
import 'about_screen.dart';
import 'package:keyah/models/association.dart';
import 'package:keyah/styles/colors.dart';

class HomeScreen extends StatefulWidget {
  final List<Association> allAssociations; 

  // CORRECCIÓN 1: Usamos 'super.key' para limpiar el código
  const HomeScreen({super.key, required this.allAssociations});

  @override
  // CORRECCIÓN 2: Cambiamos el tipo de retorno a 'State<HomeScreen>' (público)
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // 1. Controlador para manejar el deslizamiento de las páginas
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador en la página 0
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose(); // Limpiamos el controlador al salir
    super.dispose();
  }

  // Lista de pantallas (Getter)
  List<Widget> get _screens => [
        AssociationSearchScreen(allAssociations: widget.allAssociations), 
        ReportsScreen(),
        AboutScreen(),
      ];

  // 2. Lógica al tocar la barra de navegación
  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Hacemos que el PageView se mueva hacia la página seleccionada suavemente
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // 3. Lógica al deslizar la pantalla (Swipe)
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      
      // 4. CAMBIO PRINCIPAL: Usamos PageView en lugar de IndexedStack
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged, // Detecta cuando arrastras el dedo
        physics: const BouncingScrollPhysics(), // Efecto rebote (opcional, se siente bien en iOS/Android)
        children: _screens,
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: CurvedNavigationBar(
          index: _selectedIndex, // Esto asegura que la burbuja se mueva si deslizas la pantalla
          height: 60.0,
          items: const <Widget>[
            Icon(Icons.search, size: 30, color: Colors.white),
            Icon(Icons.bar_chart, size: 30, color: Colors.white),
            Icon(Icons.info_outline, size: 30, color: Colors.white),
          ],
          color: KeyahColors.primaryBlue,
          buttonBackgroundColor: KeyahColors.primaryBlue,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: _onNavBarTapped, // Usamos nuestra función personalizada
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}