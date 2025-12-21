import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para el Clipboard
import 'package:keyah/models/association.dart';
import 'package:keyah/styles/colors.dart';

class DonationModal extends StatelessWidget {
  final Association association;

  const DonationModal({required this.association, super.key});

  @override
  Widget build(BuildContext context) {
    // Altura controlada para que no ocupe toda la pantalla, pero sí lo suficiente
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            centerTitle: true,
            title: Text(
              'Apoya a ${association.nombre}',
              style: const TextStyle(color: KeyahColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            bottom: const TabBar(
              labelColor: KeyahColors.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: KeyahColors.primaryBlue,
              tabs: [
                Tab(icon: Icon(Icons.volunteer_activism), text: "Datos Bancarios"),
                Tab(icon: Icon(Icons.receipt_long), text: "Solicitar Factura"),
              ],
            ),
          ),
          body: Container(
            color: Colors.white,
            child: TabBarView(
              children: [
                _buildDonationTab(context),
                _buildInvoiceTab(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB 1: DATOS PARA DONAR (CON DIMO) ---
  Widget _buildDonationTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Tu donativo llega íntegro (0% comisiones)",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        
        // Tarjeta de Datos
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildCopyRow(context, "Banco", "BBVA Bancomer"), // Hardcodeado o variable
              const Divider(),
              _buildCopyRow(context, "CLABE", "012 180 0155443322 1"), // Hardcodeado o variable
              const Divider(),
              
              // --- AGREGADO: DIMO (Usando el teléfono) ---
              _buildCopyRow(
                context, 
                "DiMo (Celular)", 
                association.dimo ?? "No disponible"
              ),
              const Divider(),
              
              _buildCopyRow(context, "Concepto", "Donativo Keyah"),
            ],
          ),
        ),

        const SizedBox(height: 30),
        const Text(
          "¿Prefieres CoDi?",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Placeholder del QR (En el futuro cargarás la imagen real)
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                Text("QR no configurado", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Escanea desde tu app bancaria",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: EL PLAYBOOK DE FACTURACIÓN ---
  Widget _buildInvoiceTab(BuildContext context) {
    // Si 'correos' es nulo, usamos una lista vacía para evitar errores
    final List<String> emailDestino = association.correos ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: KeyahColors.lightBackground, // Un azul muy clarito
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: KeyahColors.primaryBlue.withOpacity(0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: KeyahColors.primaryBlue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Para emitir tu deducible, la asociación requiere tus datos fiscales actualizados.",
                  style: TextStyle(fontSize: 13, color: KeyahColors.primaryBlue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        
        const Text("Pasos a seguir:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 15),
        
        _buildStep(1, "Realiza tu transferencia o pago CoDi."),
        _buildStep(2, "Toma una captura de pantalla del comprobante."),
        _buildStep(3, "Envía un correo adjuntando:\n• La captura del pago.\n• Tu Constancia de Situación Fiscal (PDF)."),
        
        const SizedBox(height: 30),

        // EL BOTÓN MÁGICO
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: KeyahColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          icon: const Icon(Icons.copy, color: Colors.white),
          label: const Text("Copiar Plantilla de Correo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            // Convierte la lista en un solo texto separado por comas
            _copiarPlantilla(context, emailDestino.isNotEmpty ? emailDestino.join(', ') : 'contacto@asociacion.org');
          },
        ),
        const SizedBox(height: 10),
        const Text(
          "Copia el texto, abre tu correo y pégalo. Solo tendrás que adjuntar los archivos.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // Widget auxiliar para filas con botón de copiar
  Widget _buildCopyRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20, color: KeyahColors.primaryBlue),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copiado')),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[200],
            child: Text("$number", style: const TextStyle(fontSize: 12, color: Colors.black)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }

  // Lógica para generar el texto del correo
  void _copiarPlantilla(BuildContext context, String email) {
    final body = """
Hola, acabo de realizar un donativo a través de Keyah.

Adjunto a este correo encontrarán:
1. Comprobante de la transferencia.
2. Mi Constancia de Situación Fiscal (PDF).

Por favor emitir la factura con los siguientes detalles:
- Uso de CFDI: G02 - Donativos (o el que aplique)
- Régimen Fiscal: (Mi régimen viene en la constancia)

Quedo atento a su respuesta.
    """;

    Clipboard.setData(ClipboardData(text: body));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plantilla copiada. ¡Ahora pégala en tu correo!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}