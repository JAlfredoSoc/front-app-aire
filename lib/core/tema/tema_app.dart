import 'package:flutter/material.dart';
import 'colores.dart';

/// Tema global de la aplicación.
abstract final class TemaApp {
  static ThemeData get oscuro => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColores.fondo,
    colorScheme: const ColorScheme.dark(
      primary: AppColores.verde,
      surface: AppColores.fondoCard,
    ),
    fontFamily: 'Roboto',
    useMaterial3: true,
  );
}
