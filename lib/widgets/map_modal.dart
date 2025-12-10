import 'package:flutter/material.dart';
import 'package:keyah/styles/colors.dart';
import 'package:keyah/utils/launchers.dart';

class MapModal extends StatelessWidget {
  // ACEPTAMOS LOS DATOS INDIVIDUALES PARA COINCIDIR CON LA PANTALLA DE BÚSQUEDA
  final String address;
  final String city;
  final String state;

  const MapModal({
    required this.address,
    required this.city,
    required this.state,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Construimos la dirección completa para mostrarla y para enviarla a Google Maps
    final String fullAddress = "$address, $city, $state";

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          
          const Icon(Icons.map_outlined, size: 48, color: KeyahColors.primaryBlue),
          const SizedBox(height: 16),
          
          const Text(
            'Ubicación',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: KeyahColors.darkText),
          ),
          const SizedBox(height: 8),
          
          Text(
            // Si la dirección está vacía, mostramos al menos ciudad y estado
            address.isNotEmpty ? fullAddress : '$city, $state',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Botón Principal: Abrir Mapa Real
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 2. Usamos la función corregida de Launchers que acepta una dirección (String)
                Launchers.launchMap(fullAddress);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.directions),
              label: const Text('Abrir en Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KeyahColors.actionOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}