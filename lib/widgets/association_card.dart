import 'package:flutter/material.dart';
import 'package:keyah/styles/colors.dart';
import 'package:keyah/models/association.dart';

class AssociationCard extends StatelessWidget {
  final Association association;
  final VoidCallback onDetailsPressed;
  final VoidCallback onMapPressed;

  const AssociationCard({
    required this.association,
    required this.onDetailsPressed,
    required this.onMapPressed,
    super.key,
  });

  // --- LÓGICA DEL DIÁLOGO DE DONACIÓN ---
  void _showDonationDialog(BuildContext context) {
    final bool hasQr = association.qrImagen != null && association.qrImagen!.isNotEmpty;
    final String monto = association.montoSugerido ?? 'Tu aporte es valioso';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: KeyahColors.actionOrange,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.volunteer_activism, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Apoya esta causa',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            if (hasQr) ...[
              const Text('Escanea para donar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    'assets/qrs/${association.qrImagen}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2, size: 50, color: Colors.grey),
                            Text('QR no disponible', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        )
                      );
                    },
                  ),
                ),
              ),
            ] else 
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Esta asociación aún no ha configurado su código QR.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              ),

            const SizedBox(height: 16),
            const Text('Monto sugerido', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(
              monto, 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: KeyahColors.primaryBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: Nombre y Temática
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    association.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: KeyahColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildTopicChip(association.tematica),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Ubicación (Ciudad)
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${association.ciudad}, ${association.estado}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Divider(height: 20, color: Color(0xFFEEEEEE)),
            
            // Dirección (Muestra previa)
            Text(
              association.direccion.isNotEmpty ? association.direccion : 'Dirección no especificada',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: KeyahColors.darkText),
            ),
            
            const SizedBox(height: 12),
            
            // Botones de Acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 1. Botón Donar (Nuevo - A la izquierda)
                TextButton.icon(
                  onPressed: () => _showDonationDialog(context),
                  icon: const Icon(Icons.volunteer_activism, size: 18, color: KeyahColors.actionOrange),
                  label: const Text('Donar', style: TextStyle(color: KeyahColors.actionOrange)),
                  style: TextButton.styleFrom(
                    foregroundColor: KeyahColors.actionOrange,
                  ),
                ),
                
                // 2. Botón Mapa
                TextButton.icon(
                  onPressed: onMapPressed,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Mapa'),
                  style: TextButton.styleFrom(
                    foregroundColor: KeyahColors.primaryBlue,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 3. Botón Contacto (Destacado)
                ElevatedButton.icon(
                  onPressed: onDetailsPressed,
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Contacto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KeyahColors.actionOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper para construir la etiqueta de temática pequeña
  Widget _buildTopicChip(String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: KeyahColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        topic,
        style: const TextStyle(
          color: KeyahColors.primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}