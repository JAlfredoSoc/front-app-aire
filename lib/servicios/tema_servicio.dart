import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/tema/tema_app.dart';

/// Servicio para gestionar el tema de la aplicación (oscuro/claro).
/// Guarda la preferencia del usuario en SharedPreferences.
class TemaServicio {
  TemaServicio._();

  static const String _claveTemaOscuro = 'tema_oscuro';

  /// Cambia el tema de la aplicación.
  /// [esOscuro] - true para modo oscuro, false para modo claro.
  static Future<void> cambiarTema(bool esOscuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveTemaOscuro, esOscuro);
  }

  /// Retorna el tema actual según la preferencia guardada.
  /// Por defecto retorna modo oscuro si no hay preferencia guardada.
  static Future<ThemeData> temaActual() async {
    final prefs = await SharedPreferences.getInstance();
    final esOscuro = prefs.getBool(_claveTemaOscuro) ?? true;
    return esOscuro ? TemaApp.oscuro : TemaApp.claro;
  }

  /// Retorna true si el tema actual es oscuro.
  static Future<bool> esOscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveTemaOscuro) ?? true;
  }

  /// Retorna el tema oscuro directamente (sin leer preferencia).
  static ThemeData get oscuro => TemaApp.oscuro;

  /// Retorna el tema claro directamente (sin leer preferencia).
  static ThemeData get claro => TemaApp.claro;
}
