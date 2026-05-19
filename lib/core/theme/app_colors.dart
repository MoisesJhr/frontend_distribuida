import 'package:flutter/material.dart';

class AppColors {
  // --- GENERALES ---
  static const Color white = Colors.white;
  static const Color textDark = Color(
    0xFF1A3644,
  ); // Azul muy oscuro para textos legibles
  static const Color textLight = Colors.black54;

  // --- 1. PANTALLAS INICIALES (Bienvenida, Login, Registro) ---
  // Tu azul base para dar una bienvenida limpia y minimalista
  static const Color authBackground = Color.fromARGB(255, 160, 207, 223);
  // Un tono ligeramente más oscuro para botones y bordes en esta fase
  static const Color authAccent = Color(0xFF6BABC3);

  // --- 2. PANTALLAS INTERNAS: ESTUDIANTE ---
  // Un fondo casi blanco para que no canse la vista al leer documentos
  static const Color studentBackground = Color(0xFFF4F9FA);
  // Tu azul base se convierte en el color principal para barras y botones
  static const Color studentPrimary = Color.fromARGB(255, 160, 207, 223);
  static const Color studentAccent = Color(0xFF4A90E2); // Acento vibrante

  // --- 3. PANTALLAS INTERNAS: ADMINISTRADOR ---
  // Un gris-azulado claro y sobrio para el fondo del panel de control
  static const Color adminBackground = Color(0xFFE2E8F0);
  // El azul profundo que ya tenías, perfecto para denotar autoridad e institución
  static const Color adminPrimary = Color(0xFF030D64);
  static const Color adminAccent = Color(0xFF1E3A8A); // Acento de contraste
}
