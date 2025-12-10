import 'package:flutter/material.dart';

// Define la paleta de colores para toda la aplicación Kéyah.
// Esto permite cambiar el tema de forma centralizada sin tocar el UI.
class KeyahColors {
  // Azul Marino Suave: Transmite confianza, seriedad y seguridad.
  // Ideal para la AppBar, botones secundarios y títulos principales.
  static const Color primaryBlue = Color(0xFF0F4C81); 

  // Naranja Vibrante: Fomenta la acción y el optimismo.
  // Ideal para botones de llamada a la acción (CTA), FloatingActionButton e iconos destacados.
  static const Color actionOrange = Color(0xFFFF7F50); 

  // Verde Esperanza: Indica éxito o estados positivos.
  // Ideal para iconos de verificación, mensajes de éxito o causas ambientales.
  static const Color successGreen = Color(0xFF4CAF50); 

  // Gris Oscuro: Para texto principal, asegurando alto contraste y legibilidad.
  static const Color darkText = Color(0xFF333333); 

  // Fondo Ligero: Un blanco humo muy suave para el fondo de las pantallas,
  // que es menos cansado para la vista que el blanco puro.
  static const Color lightBackground = Color(0xFFF4F7F9); 
}