import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../modelos/sensor.dart';

/// Servicio de mediciones de calidad del aire.
/// Conecta el Frontend con el Backend FastAPI.
class SensorServicio {
  SensorServicio._();

  // URL del backend (10.0.2.2 es el alias para localhost en el emulador Android)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    return 'http://10.0.2.2:8000';
  }

  /// Caché local de las últimas mediciones obtenidas
  static List<Sensor> mediciones = [];

  /// Obtiene la lista de sensores desde el API
  static Future<List<Sensor>> obtenerTodos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/sensores'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        mediciones = data.map((json) => Sensor.fromMap(json)).toList();
        return mediciones;
      } else {
        throw Exception('Fallo al cargar sensores: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en SensorServicio: $e');
      return mediciones;
    }
  }

  // ── Promedio de todos los puntos medidos ──────────────────────────────────
  static Sensor get promedio {
    if (mediciones.isEmpty) {
      return const Sensor(
        id: 'cargando',
        zona: 'Conectando...',
        posicion: LatLng(10.4631, -73.2532),
        co2: 0,
        temperatura: 0,
        pm25: 0,
        estado: EstadoAire.buena,
      );
    }

    final n = mediciones.length;
    final co2 = mediciones.map((s) => s.co2).reduce((a, b) => a + b) / n;
    final temp =
        mediciones.map((s) => s.temperatura).reduce((a, b) => a + b) / n;
    final pm25 = mediciones.map((s) => s.pm25).reduce((a, b) => a + b) / n;

    EstadoAire estado;
    if (co2 > 800 || pm25 > 50) {
      estado = EstadoAire.alta;
    } else if (co2 > 550 || pm25 > 25) {
      estado = EstadoAire.moderada;
    } else {
      estado = EstadoAire.buena;
    }

    return Sensor(
      id: 'promedio',
      zona: 'Promedio de Valledupar',
      posicion: const LatLng(10.4631, -73.2532),
      co2: co2,
      temperatura: temp,
      pm25: pm25,
      estado: estado,
    );
  }

  // ── Alertas del historial (Podrían venir del backend también) ──────────────
  static List<AlertaMedicion> get alertas {
    return mediciones.where((s) => s.estado != EstadoAire.buena).map((s) {
      return AlertaMedicion(
        zona: s.zona,
        mensaje: 'Calidad: ${s.etiquetaEstado} (CO₂: ${s.co2.toInt()} ppm)',
        nivel: s.estado,
      );
    }).toList();
  }
}

/// Alerta generada a partir de una medición
class AlertaMedicion {
  final String zona;
  final String mensaje;
  final EstadoAire nivel;
  const AlertaMedicion({
    required this.zona,
    required this.mensaje,
    required this.nivel,
  });
}
