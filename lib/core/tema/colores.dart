import 'package:flutter/material.dart';

/// Paleta de colores centralizada de AirMonitor.
/// Usar siempre estas constantes en lugar de valores hex inline.
abstract final class AppColores {
  // Fondo - Modo Oscuro
  static const fondoOscuro = Color(0xFF0F2027);
  static const fondoCardOscuro = Color(0xFF112A34);

  // Fondo - Modo Claro
  static const fondoClaro = Color(0xFFF5F7FA);
  static const fondoCardClaro = Color(0xFFFFFFFF);

  // Gradiente de fondo (auth + contenedor base) - Modo Oscuro
  static const gradienteFondoOscuro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  );

  // Gradiente de fondo (auth + contenedor base) - Modo Claro
  static const gradienteFondoClaro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2), Color(0xFF80DEEA)],
  );

  // Acento principal (mismo para ambos modos)
  static const verde = Color(0xFF00C9A7);
  static const amarillo = Color(0xFFFFC857);
  static const rojo = Color(0xFFFF6B6B);
  static const azul = Color(0xFF7CC6FE);
  static const naranja = Color(0xFFFF9F7F);

  // Texto - Modo Oscuro
  static const textoBlanco = Colors.white;
  static const textoSecundario = Colors.white70;
  static const textoTerciario = Colors.white54;
  static const textoDeshabilitado = Colors.white38;

  // Texto - Modo Claro
  static const textoNegro = Colors.black87;
  static const textoSecundarioClaro = Colors.black54;
  static const textoTerciarioClaro = Colors.black38;
  static const textoDeshabilitadoClaro = Colors.black26;

  // Bordes y superficies - Modo Oscuro
  static const bordeCardOscuro = Colors.white12;

  // Bordes y superficies - Modo Claro
  static const bordeCardClaro = Colors.black12;
}
