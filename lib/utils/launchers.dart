import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class Launchers {
  
  // 1. LLAMADAS TELEFÓNICAS
  static Future<void> launchPhone(String phoneNumber) async {
    // Limpiamos el número dejando solo dígitos y el símbolo +
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Error al llamar: $e');
    }
  }

  // 2. CORREOS ELECTRÓNICOS
  static Future<void> launchEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Error al enviar correo: $e');
    }
  }

  // 3. REDES SOCIALES / WEBS
  static Future<void> launchWeb(String url) async {
    // 1. Limpieza básica: si el usuario no puso https://, se lo agregamos
    String cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    final Uri launchUri = Uri.parse(cleanUrl);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('No se pudo abrir el navegador: $cleanUrl');
      }
    } catch (e) {
      debugPrint('Error lanzando URL: $e');
    }
  }

  // 4. MAPAS
  static Future<void> launchMap(String address) async {
    // A. Codificamos la dirección para URL (convierte espacios en %20, etc.)
    final String query = Uri.encodeComponent(address);
    
    // B. Usamos la URL ESTÁNDAR de Google Maps
    final Uri mapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    try {
      // C. Lanzamos la URL forzando una aplicación externa
      // Usamos 'launchUrl' directamente. Si devuelve false, es que falló.
      if (!await launchUrl(mapsUrl, mode: LaunchMode.externalApplication)) {
        debugPrint('No se pudo abrir el mapa para: $address');
      }
    } catch (e) {
      debugPrint('Error al lanzar mapa: $e');
    }
  }
}