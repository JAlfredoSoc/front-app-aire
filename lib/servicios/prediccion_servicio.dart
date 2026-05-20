import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrediccionServicio {
  PrediccionServicio._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    return 'http://10.0.2.2:8000';
  }

  /// Realiza una predicción de CO2 para las próximas X horas
  /// Retorna un mapa con el valor predicho y el nivel de riesgo
  static Future<Map<String, dynamic>?> predecir(String idSensor, {int horas = 3}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/predicciones/$idSensor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_sensor': idSensor,
          'horas_futura': horas,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error en predicción: $e');
      return null;
    }
  }

  /// Entrena el modelo CNN con los datos reales en Firebase
  static Future<Map<String, dynamic>> entrenarModelo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/predicciones/entrenar'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Obtiene estadísticas globales de la IA (efectividad y uso)
  static Future<Map<String, dynamic>> obtenerEstadisticasGlobales() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/predicciones/estadisticas/globales'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'efectividad_ia': 0.0, 'total_predicciones': 0};
    } catch (e) {
      debugPrint('Error obteniendo estadísticas: $e');
      return {'efectividad_ia': 0.0, 'total_predicciones': 0};
    }
  }
}
