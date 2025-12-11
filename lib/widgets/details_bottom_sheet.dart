import 'package:flutter/material.dart';
import 'package:keyah/styles/colors.dart';
import 'package:keyah/models/association.dart';
import 'package:keyah/utils/launchers.dart';
import 'package:keyah/services/database_helper.dart';

class DetailsBottomSheet extends StatefulWidget {
  final Association association;

  const DetailsBottomSheet({required this.association, super.key});

  @override
  State<DetailsBottomSheet> createState() => _DetailsBottomSheetState();
}

class _DetailsBottomSheetState extends State<DetailsBottomSheet> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<String> _phones = [];
  List<String> _emails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContactDetails();
  }

  Future<void> _loadContactDetails() async {
    try {
      final phones = await _dbHelper.getPhonesForAssociation(widget.association.id);
      final emails = await _dbHelper.getEmailsForAssociation(widget.association.id);
      
      if (mounted) {
        setState(() {
          _phones = phones;
          _emails = emails;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando detalles: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calculamos cuánto espacio ocupa la barra del sistema (si existe)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      // 2. Sumamos ese espacio al padding inferior original (24 + bottomPadding)
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de arrastre
          Center(
            child: Container(
              width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Título de la Asociación
          Text(
            widget.association.nombre,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: KeyahColors.primaryBlue),
          ),
          const SizedBox(height: 8),
          
          // Ciudad y Estado
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${widget.association.ciudad}, ${widget.association.estado}', 
                  style: const TextStyle(color: Colors.grey)
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // CONTENIDO PRINCIPAL (Scrollable)
          _isLoading 
            ? const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: KeyahColors.actionOrange)
                ),
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECCIÓN 1: DIRECCIÓN FÍSICA
                      if (widget.association.direccion.isNotEmpty) ...[
                        _buildSectionHeader('Dirección Física'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: KeyahColors.lightBackground, 
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Text(
                            widget.association.direccion, 
                            style: const TextStyle(color: KeyahColors.darkText, height: 1.4)
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // SECCIÓN 2: TELÉFONOS (Con InkWell)
                      _buildSectionHeader('Teléfonos'),
                      const SizedBox(height: 8),
                      if (_phones.isEmpty)
                        _buildEmptyMessage('No hay teléfonos registrados')
                      else
                        ..._phones.map((phone) => _buildContactCard(
                          icon: Icons.phone,
                          color: KeyahColors.actionOrange,
                          label: 'Teléfono',
                          value: phone,
                          onTap: () => Launchers.launchPhone(phone),
                        )),

                      const SizedBox(height: 16),

                      // SECCIÓN 3: CORREOS (Con InkWell)
                      _buildSectionHeader('Correos Electrónicos'),
                      const SizedBox(height: 8),
                      if (_emails.isEmpty)
                        _buildEmptyMessage('No hay correos registrados')
                      else
                        ..._emails.map((email) => _buildContactCard(
                          icon: Icons.email,
                          color: KeyahColors.primaryBlue,
                          label: 'Email',
                          value: email,
                          onTap: () => Launchers.launchEmail(email),
                        )),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          
          const SizedBox(height: 20),
          
          // Botón de Cerrar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: KeyahColors.darkText,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  // Nuevo Widget con InkWell para mejor experiencia de usuario
  Widget _buildContactCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: KeyahColors.lightBackground, // Fondo sutil
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias, // Asegura que el ripple respete los bordes
        child: InkWell(
          onTap: onTap,
          splashColor: color.withOpacity(0.1), // Color del efecto al tocar
          highlightColor: color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label, 
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500
                        )
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value, 
                        style: const TextStyle(
                          color: KeyahColors.darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                        )
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title, 
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 16, 
          color: KeyahColors.darkText
        ),
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        message, 
        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }
}