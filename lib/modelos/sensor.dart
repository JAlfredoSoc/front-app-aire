import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Estados posibles de calidad del aire
enum EstadoAire { buena, moderada, alta }

/// Modelo de una medición de calidad del aire.
/// Representa un punto donde el sensor físico tomó una lectura.
/// Compatible con datos estáticos, Firebase o API REST.
class Sensor {
  final String id;
  final String zona;
  final LatLng posicion;
  final double co2; // ppm
  final double temperatura; // °C
  final double pm25; // µg/m³
  final EstadoAire estado;

  const Sensor({
    required this.id,
    required this.zona,
    required this.posicion,
    required this.co2,
    required this.temperatura,
    required this.pm25,
    required this.estado,
  });

  /// Color del marcador según el estado
  Color get colorEstado {
    switch (estado) {
      case EstadoAire.buena:
        return const Color(0xFF00C9A7);
      case EstadoAire.moderada:
        return const Color(0xFFFFC857);
      case EstadoAire.alta:
        return const Color(0xFFFF6B6B);
    }
  }

  /// Etiqueta legible del estado
  String get etiquetaEstado {
    switch (estado) {
      case EstadoAire.buena:
        return 'Buena';
      case EstadoAire.moderada:
        return 'Moderada';
      case EstadoAire.alta:
        return 'Alta';
    }
  }

  /// Factory para construir desde Map (Firebase / REST)
  factory Sensor.fromMap(Map<String, dynamic> map) {
    return Sensor(
      id: map['id'] as String,
      zona: map['zona'] as String,
      posicion: LatLng(
        (map['lat'] as num).toDouble(),
        (map['lng'] as num).toDouble(),
      ),
      co2: (map['co2'] as num).toDouble(),
      temperatura: (map['temperatura'] as num).toDouble(),
      pm25: (map['pm25'] as num).toDouble(),
      estado: EstadoAire.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoAire.buena,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'zona': zona,
    'lat': posicion.latitude,
    'lng': posicion.longitude,
    'co2': co2,
    'temperatura': temperatura,
    'pm25': pm25,
    'estado': estado.name,
  };
}
