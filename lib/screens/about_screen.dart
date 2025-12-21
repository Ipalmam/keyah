import 'package:flutter/material.dart';
import 'package:keyah/styles/colors.dart';
import 'package:keyah/utils/launchers.dart'; 

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // CONFIGURACIÓN FINAL:
  final String _contactEmail = 'lanu.soy.yo@gmail.com'; 
  final String _arewaLabsUrl = 'https://www.arewalabs.com'; 
  
  // Datos de la app
  final String _appVersion = 'v1.0.0';
  
  // -- URLs LEGALES ACTUALIZADAS --
  // Asegúrate de que estas rutas coincidan con donde subas los archivos en tu servidor
  final String _privacyPolicyUrl = 'https://www.arewalabs.com/apps/keyah-privacidad.html'; 
  final String _termsUrl = 'https://www.arewalabs.com/apps/keyah-terminos.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Acerca de Keyah',
          style: TextStyle(fontWeight: FontWeight.bold, color: KeyahColors.darkText),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // 1. LOGO E IDENTIDAD 
            Container(
              padding: const EdgeInsets.all(24), 
              decoration: BoxDecoration(
                color: KeyahColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/studio_logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Keyah',
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.w900, 
                color: KeyahColors.primaryBlue,
                letterSpacing: 1.0,
              ),
            ),
            
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Versión $_appVersion',
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 40),

            // 2. MISIÓN / DESCRIPCIÓN
            const Text(
              'Comunidad y Territorio',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: KeyahColors.darkText),
            ),
            const SizedBox(height: 12),
            const Text(
              'Keyah es una plataforma diseñada para visibilizar y fortalecer a las Asociaciones Civiles en México. Nuestra misión es facilitar el enlace entre quienes necesitan ayuda, quienes quieren ayudar y las instituciones que hacen posible el cambio en nuestro territorio compartido.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.6, fontSize: 15),
            ),

            const SizedBox(height: 40),

            // --- INCENTIVO PARA SOLUCIONES ---
            _buildSupportHeader('¿Tienes un Reto que Resolver?'),
            const SizedBox(height: 10),
            _buildSupportText(
              'Buscamos activamente problemas sociales o comunitarios que puedan ser transformados en soluciones digitales. Cuéntanos qué retos enfrentas; si podemos resolverlo con código, lo crearemos y te daremos crédito en la próxima app, abriendo puertas a nuevas oportunidades y empleo.',
            ),
            const SizedBox(height: 16),
            _buildSupportButton(
              url: _arewaLabsUrl,
              label: '¡Colabora con Arewa Labs!',
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),
            
            // 3. CONTACTO
            _buildOptionTile(
              icon: Icons.email_outlined,
              title: 'Contáctanos',
              subtitle: 'Escribe a Lanu, tu asistente de soporte',
              onTap: () => Launchers.launchEmail(_contactEmail),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),

            // 4. SECCIÓN LEGAL (ACTUALIZADA)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  "LEGAL",
                  style: TextStyle(
                    color: Colors.grey[400], 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12,
                    letterSpacing: 1.2
                  ),
                ),
              ),
            ),

            _buildOptionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Aviso de Privacidad',
              subtitle: 'Consulta cómo protegemos tus datos',
              onTap: () => Launchers.launchWeb(_privacyPolicyUrl),
            ),

            _buildOptionTile(
              icon: Icons.gavel_outlined, // Icono de mazo legal
              title: 'Términos y Condiciones',
              subtitle: 'Reglas de uso y deslinde financiero',
              onTap: () => Launchers.launchWeb(_termsUrl),
            ),

            // NUEVO: Licencias de Software (Flutter nativo)
            _buildOptionTile(
              icon: Icons.code, 
              title: 'Licencias de Código Abierto',
              subtitle: 'Software utilizado para construir Keyah',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Keyah',
                applicationVersion: _appVersion,
                applicationLegalese: '© ${DateTime.now().year} Arewa Labs',
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('assets/images/studio_logo.png', width: 50, height: 50),
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // 5. COPYRIGHT
            Text(
              '© ${DateTime.now().year} Keyah México.\nTodos los derechos reservados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Auxiliar para el título del incentivo
  Widget _buildSupportHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: KeyahColors.actionOrange,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Widget Auxiliar para el texto de incentivo
  Widget _buildSupportText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[700], height: 1.6),
      ),
    );
  }

  // Widget Auxiliar para el botón de acción
  Widget _buildSupportButton({required String url, required String label}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Launchers.launchWeb(url),
        icon: const Icon(Icons.code, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: KeyahColors.actionOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          shadowColor: KeyahColors.actionOrange.withOpacity(0.4),
        ),
      ),
    );
  }

  // Widget auxiliar para las opciones de lista
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KeyahColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: KeyahColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: KeyahColors.darkText,
                      fontSize: 16
                    )
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle, 
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}