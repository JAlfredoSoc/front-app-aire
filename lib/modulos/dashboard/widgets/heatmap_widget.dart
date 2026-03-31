import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SensorMapa {
  final String id;
  final String nombre;
  final LatLng posicion;
  final int co2;
  final int particulas;
  final int temperatura;
  final Color color;
  final double radio;

  const SensorMapa({
    required this.id,
    required this.nombre,
    required this.posicion,
    required this.co2,
    required this.particulas,
    required this.temperatura,
    required this.color,
    required this.radio,
  });

  String get resumen =>
      'CO₂: $co2 ppm · PM2.5: $particulas µg/m³ · $temperatura °C';
}

class HeatmapWidget {
  const HeatmapWidget._();

  static const LatLng centroValledupar = LatLng(10.4631, -73.2532);

  static const List<SensorMapa> sensores = [
    SensorMapa(
      id: 'centro',
      nombre: 'Centro Histórico',
      posicion: LatLng(10.4637, -73.2528),
      co2: 45,
      particulas: 18,
      temperatura: 27,
      color: Color(0xFF00C9A7),
      radio: 260,
    ),
    SensorMapa(
      id: 'novalito',
      nombre: 'Novalito',
      posicion: LatLng(10.4686, -73.2622),
      co2: 85,
      particulas: 32,
      temperatura: 29,
      color: Color(0xFFFFC857),
      radio: 340,
    ),
    SensorMapa(
      id: 'nevada',
      nombre: 'La Nevada',
      posicion: LatLng(10.4552, -73.2465),
      co2: 152,
      particulas: 46,
      temperatura: 31,
      color: Color(0xFFFF6B6B),
      radio: 420,
    ),
  ];
}
