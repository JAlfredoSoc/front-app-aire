import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapaCalorServicio {
  MapaCalorServicio._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    return 'http://10.0.2.2:8000';
  }

  /// Obtiene los puntos del mapa de calor interpolados desde el backend.
  /// [tipo] puede ser 'co2', 'pm25' o 'temperatura'.
  static Future<List<Map<String, dynamic>>> obtenerPuntos(String tipo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/mapa-calor/?tipo=$tipo'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('puntos')) {
          final List<dynamic> puntosRaw = data['puntos'];
          return puntosRaw.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error obteniendo mapa de calor: $e');
      return [];
    }
  }
}
