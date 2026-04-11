import 'package:flutter/material.dart';

/// Paleta de colores centralizada de AirMonitor.
/// Usar siempre estas constantes en lugar de valores hex inline.
abstract final class AppColores {
  // Fondo
  static const fondo = Color(0xFF0F2027);
  static const fondoCard = Color(0xFF112A34);

  // Gradiente de fondo (auth + contenedor base)
  static const gradienteFondo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  );

  // Acento principal
  static const verde = Color(0xFF00C9A7);
  static const amarillo = Color(0xFFFFC857);
  static const rojo = Color(0xFFFF6B6B);
  static const azul = Color(0xFF7CC6FE);
  static const naranja = Color(0xFFFF9F7F);

  // Texto
  static const textoBlanco = Colors.white;
  static const textoSecundario = Colors.white70;
  static const textoTerciario = Colors.white54;
  static const textoDeshabilitado = Colors.white38;

  // Bordes y superficies
  static const bordeCard = Colors.white12;
}
