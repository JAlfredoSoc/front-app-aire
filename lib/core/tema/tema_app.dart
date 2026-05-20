import 'package:flutter/material.dart';
import 'colores.dart';

/// Tema global de la aplicación.
abstract final class TemaApp {
  static ThemeData get oscuro => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColores.fondoOscuro,
    colorScheme: const ColorScheme.dark(
      primary: AppColores.verde,
      surface: AppColores.fondoCardOscuro,
      onSurface: AppColores.textoBlanco,
      onPrimary: Colors.white,
      error: AppColores.rojo,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColores.textoBlanco),
      displayMedium: TextStyle(color: AppColores.textoBlanco),
      displaySmall: TextStyle(color: AppColores.textoBlanco),
      headlineLarge: TextStyle(color: AppColores.textoBlanco),
      headlineMedium: TextStyle(color: AppColores.textoBlanco),
      headlineSmall: TextStyle(color: AppColores.textoBlanco),
      titleLarge: TextStyle(color: AppColores.textoBlanco),
      titleMedium: TextStyle(color: AppColores.textoBlanco),
      titleSmall: TextStyle(color: AppColores.textoBlanco),
      bodyLarge: TextStyle(color: AppColores.textoBlanco),
      bodyMedium: TextStyle(color: AppColores.textoBlanco),
      bodySmall: TextStyle(color: AppColores.textoSecundario),
      labelLarge: TextStyle(color: AppColores.textoBlanco),
      labelMedium: TextStyle(color: AppColores.textoBlanco),
      labelSmall: TextStyle(color: AppColores.textoSecundario),
    ),
    fontFamily: 'Roboto',
    useMaterial3: true,
  );

  static ThemeData get claro => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColores.fondoClaro,
    colorScheme: const ColorScheme.light(
      primary: AppColores.verde,
      surface: AppColores.fondoCardClaro,
      onSurface: AppColores.textoNegro,
      onPrimary: Colors.white,
      error: AppColores.rojo,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColores.textoNegro),
      displayMedium: TextStyle(color: AppColores.textoNegro),
      displaySmall: TextStyle(color: AppColores.textoNegro),
      headlineLarge: TextStyle(color: AppColores.textoNegro),
      headlineMedium: TextStyle(color: AppColores.textoNegro),
      headlineSmall: TextStyle(color: AppColores.textoNegro),
      titleLarge: TextStyle(color: AppColores.textoNegro),
      titleMedium: TextStyle(color: AppColores.textoNegro),
      titleSmall: TextStyle(color: AppColores.textoNegro),
      bodyLarge: TextStyle(color: AppColores.textoNegro),
      bodyMedium: TextStyle(color: AppColores.textoNegro),
      bodySmall: TextStyle(color: AppColores.textoSecundarioClaro),
      labelLarge: TextStyle(color: AppColores.textoNegro),
      labelMedium: TextStyle(color: AppColores.textoNegro),
      labelSmall: TextStyle(color: AppColores.textoSecundarioClaro),
    ),
    fontFamily: 'Roboto',
    useMaterial3: true,
  );
}
