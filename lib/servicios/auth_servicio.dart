import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthServicio {
  AuthServicio._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    return 'http://10.0.2.2:8000';
  }

  /// Iniciar sesión con email y password
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final userData = data['usuario'];
        
        // Guardar token y datos localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_email', userData['email'] ?? email);
        await prefs.setString('user_nombre', userData['nombre'] ?? 'Usuario');
        // Guardar uid para uso en biometría
        if (userData['uid'] != null) {
          await prefs.setString('user_uid', userData['uid']);
        }
        // Guardar última conexión
        if (userData['ultima_conexion'] != null) {
          await prefs.setString('user_ultima_conexion', userData['ultima_conexion']);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error en login: $e');
      return false;
    }
  }

  /// Registrar un nuevo usuario
  static Future<bool> registro(String nombre, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Después de registrar, hacemos login automático
        return await login(email, password);
      }
      return false;
    } catch (e) {
      debugPrint('Error en registro: $e');
      return false;
    }
  }

  /// Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_email');
    await prefs.remove('user_nombre');
    await prefs.remove('user_uid');
    await prefs.remove('user_ultima_conexion');
  }

  /// Obtiene el UID del usuario logueado.
  static Future<String?> obtenerUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  /// Verificar si hay una sesión activa
  static Future<bool> estaLogueado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('jwt_token');
  }
}
